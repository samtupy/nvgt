/* pack2.h - pack API version 2 implementation header
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

#pragma once

#include "sqlite3.h"
#include <cstdint>
#include <unordered_map>
#include <Poco/RefCountedObject.h>
#include <scriptarray.h>
#include <vector>

class asIScriptEngine;

class pack : public Poco::RefCountedObject {
private:
	sqlite3* db;
	std::unordered_map<std::uint64_t, sqlite3_blob*> pack_streams;
public:
	pack();
	bool open(const std::string& filename, int mode, const std::string& key);
	bool rekey(const std::string& key);
	bool close();
	bool add_file(const std::string& disk_filename, const std::string& pack_filename, bool allow_replace = false);
	bool add_memory(const std::string& pack_filename, unsigned char* data, unsigned int size, bool allow_replace = false);
	bool add_memory(const std::string& pack_filename, const std::string& data, bool allow_replace = false);
	bool delete_file(const std::string& pack_filename);
	bool file_exists(const std::string& pack_filename);
	std::string get_file_name(std::int64_t idx);
	void list_files(std::vector<std::string>& files);
	CScriptArray* list_files();
	std::uint64_t get_file_size(const std::string& pack_filename);
	unsigned int read_file(const std::string& pack_filename, unsigned int offset, unsigned char* buffer, unsigned int size);
	std::string read_file_string(const std::string& pack_filename, unsigned int offset, unsigned int size);
	std::uint64_t size();
	bool is_active() {
		return db;
	};
};

void RegisterScriptPack(asIScriptEngine* engine);
