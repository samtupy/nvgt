/* pack.cpp - pack API version 2 implementation
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#define NVGT_PLUGIN_INCLUDE
#include "../../src/nvgt_plugin.h"
#include "pack.h"
#include "sqlite3.h"
#include <limits>
#include <cstdint>
#include <stdexcept>
#include <Poco/Format.h>
#include <fstream>
#include <filesystem>
#include <mutex>
#include "xchacha_cipher.h"
#include <Poco/StreamUtil.h>
#include <algorithm>

using namespace std;

static once_flag SQLITE3MC_INITIALIZER;

pack::pack() {
	db = nullptr;
	call_once(SQLITE3MC_INITIALIZER, []() {
		sqlite3_initialize();
		#ifdef SQLITE3MC_H_
		if (const auto rc = nvgt_sqlite_register_cipher(); rc != SQLITE_OK) {
			throw runtime_error(Poco::format("Internal error: can't register cipher: %s", string(sqlite3_errstr(rc))));
		}
		#endif
		CScriptArray::SetMemoryFunctions(std::malloc, std::free);
	});
}

bool pack::open(const string& filename, int mode, const string& key) {
	if (const auto rc = sqlite3_open_v2(filename.data(), &db, mode | SQLITE_OPEN_EXRESCODE, nullptr); rc != SQLITE_OK) {
		return false;
	}
	#ifdef SQLITE3MC_H_
	if (!key.empty()) {
		if (const auto rc = sqlite3_key_v2(db, "main", key.data(), key.size()); rc != SQLITE_OK) {
			throw runtime_error(Poco::format("Internal error: Could not set key: %s", string(sqlite3_errmsg(db))));
		}
	}
	#endif
	if (const auto rc = sqlite3_exec(db, "pragma journal_mode=wal;", nullptr, nullptr, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: could not set journaling mode: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_exec(db, "create table if not exists pack_files(file_name primary key not null unique, data); create unique index if not exists pack_files_index on pack_files(file_name);", nullptr, nullptr, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: could not create table or index: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_db_config(db, SQLITE_DBCONFIG_DEFENSIVE, 1, NULL); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: culd not set defensive mode: %s", string(sqlite3_errmsg(db))));
	}
	return true;
}

pack::~pack() {
	if (db) {
		sqlite3_close(db);
		db = nullptr;
	}
}

#ifdef SQLITE3MC_H_
bool pack::rekey(const string& key) {
	if (const auto rc = sqlite3_rekey_v2(db, "main", key.data(), key.size()); rc != SQLITE_OK) {
		return false;
	}
	return true;
}
#endif

bool pack::close() {
	if (const auto rc = sqlite3_close(db); rc != SQLITE_OK) {
		return false;
	}
	return true;
}

bool pack::add_file(const string& disk_filename, const string& pack_filename, bool allow_replace) {
	// This is a three-step process
	// We could read the entire file into memory, but this is horribly inefficient and the file could be larger than RAM
	// Thus, we first check if the file exists. If it already does and allow_replace is false, we abort; otherwise: we first perform a database insert, find the rowid, then open the blob for writing and incrementally store the blob bit by bit
	if (!filesystem::exists(disk_filename) || filesystem::file_size(disk_filename) > SQLITE_MAX_LENGTH) {
		return false;
	}
	if (file_exists(pack_filename)) {
		if (allow_replace) {
			delete_file(pack_filename);
		} else {
			return false;
		}
	}
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "insert into pack_files values(?, ?)", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_zeroblob64(stmt, 2, filesystem::file_size(disk_filename)); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	sqlite3_blob* blob;
	if (const auto rc = sqlite3_blob_open(db, "main", "pack_files", "data", sqlite3_last_insert_rowid(db), 1, &blob); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	ifstream stream(filesystem::absolute(disk_filename), ios::in | ios::binary);
	char buffer[4096];
	int offset = 0;
	while (stream) {
		stream.read(buffer, 4096);
		if (const auto rc = sqlite3_blob_write(blob, buffer, stream.gcount(), offset); rc != SQLITE_OK) {
			sqlite3_blob_close(blob);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
		offset += stream.gcount();
	}
	sqlite3_blob_close(blob);
	return true;
}

bool pack::add_directory(const string& dir, bool allow_replace) {
	if (!filesystem::exists(dir) || !filesystem::is_directory(dir)) return false;
	if (const auto rc = sqlite3_exec(db, "begin immediate transaction;", nullptr, nullptr, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Could not begin transaction: %s", string(sqlite3_errmsg(db))));
	}
	// To do: make the following process a lot more robust
	for (const auto& f: filesystem::recursive_directory_iterator(dir)) {
		// Skip certain types of files where reading from them would be nonsensical
		if (!f.is_regular_file()) continue;
		auto p = f.path().string();
		ranges::replace(p, '\\', '/');
		if (!add_file(f.path().string(), p, allow_replace)) {
			if (!sqlite3_get_autocommit(db))
				sqlite3_exec(db, "rollback;", nullptr, nullptr, nullptr);
			return false;
		}
	}
	if (const auto rc = sqlite3_exec(db, "commit;", nullptr, nullptr, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Could not commit transaction: %s", string(sqlite3_errmsg(db))));
	}
return true;
}

bool pack::add_memory(const string& pack_filename, unsigned char* data, unsigned int size, bool allow_replace) {
	if (size > SQLITE_MAX_LENGTH) {
		return false;
	}
	if (file_exists(pack_filename)) {
		if (!allow_replace) return false;
		delete_file(pack_filename);
	}
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "insert into pack_files values(?, ?)", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("An internal error has occurred, and this should never happen! Please report the following error to the NVGT developers: %s", sqlite3_errmsg(db)));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_blob64(stmt, 2, data, size, SQLITE_STATIC); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return true;
}

bool pack::add_memory(const string& pack_filename, const string& data, bool allow_replace) {
	if (data.size() > SQLITE_MAX_LENGTH || data.empty()) {
		return false;
	}
	if (file_exists(pack_filename)) {
		if (!allow_replace) return false;
		delete_file(pack_filename);
	}
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "insert into pack_files values(?, ?)", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("An internal error has occurred, and this should never happen! Please report the following error to the NVGT developers: %s", sqlite3_errmsg(db)));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_blob64(stmt, 2, data.data(), data.size(), SQLITE_STATIC); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return true;
}

bool pack::delete_file(const string& pack_filename) {
	if (!file_exists(pack_filename)) {
		return false;
	}
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "delete from pack_files where file_name = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return true;
}

bool pack::file_exists(const string& pack_filename) {
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "select file_name from pack_files where file_name = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else if (rc == SQLITE_ROW) {
			sqlite3_finalize(stmt);
			return true;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return false;
}

string pack::get_file_name(const int64_t idx) {
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "select file_name from pack_files where rowid = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_int64(stmt, 1, idx); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else if (rc == SQLITE_ROW) {
			std::string name;
			name.resize(sqlite3_column_bytes(stmt, 0));
			for (auto i = 0; i < name.size(); ++i) {
				name[i] = static_cast<char>(sqlite3_column_text(stmt, 0)[i]);
			}
			sqlite3_finalize(stmt);
			return name;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return "";
}

void pack::list_files(std::vector<std::string>& files) {
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "select file_name from pack_files", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else if (rc == SQLITE_ROW) {
			std::string name;
			name.resize(sqlite3_column_bytes(stmt, 0));
			for (auto i = 0; i < name.size(); ++i) {
				name[i] = static_cast<char>(sqlite3_column_text(stmt, 0)[i]);
			}
			files.emplace_back(name);
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw std::runtime_error(Poco::format("Cannot list files: %s", sqlite3_errmsg(db)));
		}
	}
	sqlite3_finalize(stmt);
}

CScriptArray* pack::list_files() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType);
	sqlite3_stmt* count_stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "select count(*) from pack_files", -1, 0, &count_stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(count_stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(count_stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(count_stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) return nullptr;
		else if (rc == SQLITE_ROW) {
			array->Reserve(sqlite3_column_int64(count_stmt, 0));
			break;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(count_stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(count_stmt);
	sqlite3_stmt* names_stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "select file_name from pack_files", -1, 0, &names_stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(names_stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(names_stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(names_stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else if (rc == SQLITE_ROW) {
			std::string name;
			name.resize(sqlite3_column_bytes(names_stmt, 0));
			for (auto i = 0; i < name.size(); ++i) {
				name[i] = static_cast<char>(sqlite3_column_text(names_stmt, 0)[i]);
			}
			array->InsertLast(&name);
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(names_stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(names_stmt);
	return array;
}

uint64_t pack::get_file_size(const string& pack_filename) {
	sqlite3_stmt* stmt;
	if (const auto rc = sqlite3_prepare_v3(db, "select data from pack_files where file_name = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else if (rc == SQLITE_ROW) {
			auto size = sqlite3_column_bytes(stmt, 0);
			sqlite3_finalize(stmt);
			return size;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return 0;
}

unsigned int pack::read_file(const string& pack_filename, unsigned int offset, unsigned char* buffer, unsigned int size) {
	sqlite3_stmt* stmt;
	int64_t rowid = 0;
	if (const auto rc = sqlite3_prepare_v3(db, "select rowid from pack_files where file_name = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_ROW) {
			rowid = sqlite3_column_int64(stmt, 0);
			break;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	sqlite3_blob* blob;
	if (const auto rc = sqlite3_blob_open(db, "main", "pack_files", "data", rowid, 0, &blob); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (offset >= sqlite3_blob_bytes(blob) || size > sqlite3_blob_bytes(blob) || (offset + size) > sqlite3_blob_bytes(blob)) {
		sqlite3_blob_close(blob);
		return 0;
	}
	if (const auto rc = sqlite3_blob_read(blob, buffer, size, offset); rc != SQLITE_OK) {
		sqlite3_blob_close(blob);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	sqlite3_blob_close(blob);
	return size;
}

string pack::read_file_string(const string& pack_filename, unsigned int offset, unsigned int size) {
	sqlite3_stmt* stmt;
	int64_t rowid = 0;
	if (const auto rc = sqlite3_prepare_v3(db, "select rowid from pack_files where file_name = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, pack_filename.data(), pack_filename.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_ROW) {
			rowid = sqlite3_column_int64(stmt, 0);
			break;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	sqlite3_blob* blob;
	if (const auto rc = sqlite3_blob_open(db, "main", "pack_files", "data", rowid, 0, &blob); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (offset >= sqlite3_blob_bytes(blob) || size > sqlite3_blob_bytes(blob) || (offset + size) > sqlite3_blob_bytes(blob)) {
		sqlite3_blob_close(blob);
		return 0;
	}
	std::string res;
	res.resize(size);
	if (const auto rc = sqlite3_blob_read(blob, res.data(), size, offset); rc != SQLITE_OK) {
		sqlite3_blob_close(blob);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	sqlite3_blob_close(blob);
	return res;
}

uint64_t pack::size() {
	// For now, we only get the size of the files in the pack_files table.
	// We ignore all other tables
	// To do: switch this to possibly using DBSTAT virtual table?
	sqlite3_stmt* stmt;
	uint64_t size = 0;
	if (const auto rc = sqlite3_prepare_v3(db, "select data from pack_files", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_DONE) break;
		else if (rc == SQLITE_ROW) size += sqlite3_column_bytes(stmt, 0);
		else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return size;
}

blob_stream pack::open_file(const std::string& file_name, const bool rw) {
	if (!file_exists(file_name)) throw ios_base::failure(Poco::format("File %s does not exist", file_name));
	sqlite3_stmt* stmt;
	int64_t rowid = 0;
	if (const auto rc = sqlite3_prepare_v3(db, "select rowid from pack_files where file_name = ?", -1, 0, &stmt, nullptr); rc != SQLITE_OK) {
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	if (const auto rc = sqlite3_bind_text64(stmt, 1, file_name.data(), file_name.size(), SQLITE_STATIC, SQLITE_UTF8); rc != SQLITE_OK) {
		sqlite3_finalize(stmt);
		throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
	}
	while (true) {
		const auto rc = sqlite3_step(stmt);
		if (rc == SQLITE_BUSY)
			if (sqlite3_get_autocommit(db)) {
				sqlite3_reset(stmt);
				continue;
			} else {
				sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
				sqlite3_reset(stmt);
				continue;
			}
		else if (rc == SQLITE_ROW) {
			rowid = sqlite3_column_int64(stmt, 0);
			break;
		} else {
			if (!sqlite3_get_autocommit(db)) sqlite3_exec(db, "rollback", nullptr, nullptr, nullptr);
			sqlite3_finalize(stmt);
			throw runtime_error(Poco::format("Internal error: %s", string(sqlite3_errmsg(db))));
		}
	}
	sqlite3_finalize(stmt);
	return blob_stream(db, "main", "pack_files", "data", rowid, rw);
}

blob_stream_buf::blob_stream_buf(): Poco::BufferedBidirectionalStreamBuf(4096, ios::in) {
}

blob_stream_buf::~blob_stream_buf() {
	if (blob)
		sqlite3_blob_close(blob);
		blob = nullptr;
}

void blob_stream_buf::open(sqlite3* s, const std::string_view& db, const std::string_view& table, const std::string_view& column, const sqlite3_int64 row, const bool read_write) {
	if (read_write)
		setMode(ios::in | ios::out);
	if (const auto rc = sqlite3_blob_open(s, db.data(), table.data(), column.data(), row, static_cast<int>(read_write), &blob); rc != SQLITE_OK)
		throw runtime_error(Poco::format("%s", string(sqlite3_errmsg(s))));
}

blob_stream_buf::pos_type blob_stream_buf::seekoff(blob_stream_buf::off_type off, ios_base::seekdir dir, ios_base::openmode which) {
	if (off < 0) return -1;
	if (!(getMode() & which))
		return -1;
	if (which & ios::in)
		switch (dir) {
			case ios::beg:
				read_pos = off;
			break;
			case ios::end:
				read_pos -= off;
			break;
			case ios::cur:
				read_pos += off;
			break;
		}
	if (which & ios::out)
		switch (dir) {
			case ios::beg:
				write_pos = off;
			break;
			case ios::end:
				write_pos -= off;
			break;
			case ios::cur:
				write_pos += off;
			break;
		}
	if (read_pos >= sqlite3_blob_bytes(blob) || write_pos >= sqlite3_blob_bytes(blob))
		return -1;
	if (which & (ios::in | ios::out))
		return read_pos;
	else if (which & ios::in)
		return read_pos;
	else if (which & ios::out)
		return write_pos;
	else
		return -1;
}

blob_stream_buf::pos_type blob_stream_buf::seekpos(blob_stream_buf::pos_type pos, ios_base::openmode which) {
	if (pos < 0) return -1;
	if (!(which & getMode()))
		return -1;
	if ((which & ios::in))
		if (pos >= sqlite3_blob_bytes(blob))
			return -1;
		read_pos = pos;
	if ((which & ios::out))
		if (pos >= sqlite3_blob_bytes(blob))
			return -1;
		write_pos = pos;
	if ((which & ios::in) || (which & (ios::in | ios::out)))
		return read_pos;
	else
		return write_pos;
}

int blob_stream_buf::readFromDevice(char_type* buffer, std::streamsize length) {
	if (read_pos >= sqlite3_blob_bytes(blob) || read_pos < 0)
		return char_traits::eof();
	const auto len = (read_pos + length) % sqlite3_blob_bytes(blob);
	if (const auto rc = sqlite3_blob_read(blob, buffer, len, read_pos); rc != SQLITE_OK)
		throw runtime_error(sqlite3_errstr(rc));
	read_pos += len;
	return len;
}

int blob_stream_buf::writeToDevice(const char_type* buffer, std::streamsize length) {
	if (write_pos >= sqlite3_blob_bytes(blob))
		return char_traits::eof();
	const auto len = (write_pos + length) % sqlite3_blob_bytes(blob);
	if (const auto rc = sqlite3_blob_write(blob, buffer, len, write_pos); rc != SQLITE_OK)
		throw runtime_error(sqlite3_errstr(rc));
	write_pos += len;
	return len;
}

blob_ios::blob_ios() {
	poco_ios_init(&_buf);
}

void blob_ios::open(sqlite3* s, const std::string_view& db, const std::string_view& table, const std::string_view& column, const sqlite3_int64 row, const bool read_write) {
	_buf.open(s, db, table, column, row, read_write);
}

blob_stream_buf* blob_ios::rdbuf() {
	return &_buf;
}

blob_stream::blob_stream(): blob_ios::blob_ios(), std::iostream::basic_iostream(&_buf) { }

blob_stream::blob_stream(sqlite3* s, const std::string_view& db, const std::string_view& table, const std::string_view& column, const sqlite3_int64 row, const bool read_write): blob_ios::blob_ios(), std::iostream::basic_iostream(&_buf) {
	open(s, db, table, column, row, read_write);
}

pack* ScriptPack_Factory() {
	return new pack();
}

void RegisterScriptPack(asIScriptEngine* engine) {
	engine->RegisterEnum("pack_open_mode");
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_READ_ONLY", SQLITE_OPEN_READONLY);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_READ_WRITE", SQLITE_OPEN_READWRITE);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_CREATE", SQLITE_OPEN_CREATE);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_URI", SQLITE_OPEN_URI);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_MEMORY", SQLITE_OPEN_MEMORY);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_NO_MUTEX", SQLITE_OPEN_NOMUTEX);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_FULL_MUTEX", SQLITE_OPEN_FULLMUTEX);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_SHARED_CACHE", SQLITE_OPEN_SHAREDCACHE);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_PRIVATE_CACHE", SQLITE_OPEN_PRIVATECACHE);
	engine->RegisterEnumValue("pack_open_mode", "SQLITE_PACK_OPEN_MODE_NO_FOLLOW", SQLITE_OPEN_NOFOLLOW);
	engine->RegisterObjectType("sqlite_pack", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("sqlite_pack", asBEHAVE_FACTORY, "sqlite_pack @p()", asFUNCTION(ScriptPack_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("sqlite_pack", asBEHAVE_ADDREF, "void f()", asMETHOD(pack, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("sqlite_pack", asBEHAVE_RELEASE, "void f()", asMETHOD(pack, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool open(const string &in filename, const int mode = SQLITE_PACK_OPEN_MODE_READ_ONLY, const string& key = \"\")", asMETHOD(pack, open), asCALL_THISCALL);
	#ifdef SQLITE3MC_H_
	engine->RegisterObjectMethod("sqlite_pack", "bool rekey(const string& key)", asMETHOD(pack, rekey), asCALL_THISCALL);
	#endif
	engine->RegisterObjectMethod("sqlite_pack", "bool close()", asMETHOD(pack, close), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool add_file(const string &in disc_filename, const string& in pack_filename, bool allow_replace = false)", asMETHOD(pack, add_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool add_directory(const string &in dir, const bool allow_replace = false)", asMETHOD(pack, add_directory), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool add_memory(const string &in pack_filename, const string& in data, bool allow_replace = false)", asMETHODPR(pack, add_memory, (const string&, const string&, bool), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool delete_file(const string &in pack_filename)", asMETHOD(pack, delete_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool file_exists(const string &in pack_filename) const", asMETHOD(pack, file_exists), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "string get_file_name(int64 index) const", asMETHODPR(pack, get_file_name, (int64_t), string), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "string[]@ list_files() const", asMETHODPR(pack, list_files, (), CScriptArray*), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "uint get_file_size(const string &in pack_filename) const", asMETHOD(pack, get_file_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "string read_file(const string &in pack_filename, uint offset_in_file, uint read_byte_count) const", asMETHOD(pack, read_file_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "bool get_active() const property", asMETHOD(pack, is_active), asCALL_THISCALL);
	engine->RegisterObjectMethod("sqlite_pack", "uint get_size() const property", asMETHOD(pack, size), asCALL_THISCALL);
}

