/* nvgt_sqlite.h - sqlite plugin header
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

#include <string>
#include "../../src/nvgt_plugin.h"
#include <scriptarray.h>
#include "sqlite3.h"
#include "sqlite3exts.h"

class sqlite3DB;
class sqlite3statement {
	int ref_count;
public:
	sqlite3DB* parent;
	sqlite3_stmt* statement;
	sqlite3statement(sqlite3DB* p, sqlite3_stmt* s);
	void add_ref();
	void release();
	int step();
	int reset();
	std::string get_expanded_sql_statement();
	std::string get_sql_statement();
	int get_bind_param_count();
	int get_column_count();
	int bind_blob(int index, const std::string& blob, bool transient = true);
	int bind_double(int index, double val);
	int bind_int(int index, int val);
	int bind_int64(int index, asINT64 val);
	int bind_null(int index);
	int bind_param_index(const std::string& name);
	std::string bind_param_name(int index);
	int bind_text(int index, const std::string& text, bool transient = true);
	int clear_bindings();
	std::string column_blob(int index);
	int column_bytes(int index);
	std::string column_decltype(int index);
	double column_double(int index);
	int column_int(int index);
	asINT64 column_int64(int index);
	std::string column_name(int index);
	int column_type(int index);
	std::string column_text(int index);
};
class sqlite3context {
	sqlite3_context* c;
	int ref_count;
public:
	sqlite3context(sqlite3_context* ctx);
	void add_ref();
	void release();
	void set_blob(const std::string& blob, bool transient = true);
	void set_double(double val);
	void set_error(const std::string& errormsg, int errorcode = SQLITE_ERROR);
	void set_int(int val);
	void set_int64(asINT64 val);
	void set_null();
	void set_text(const std::string& text, bool transient = true);
};
class sqlite3value {
	int ref_count;
public:
	sqlite3_value* v;
	sqlite3value(sqlite3_value* val);
	void add_ref();
	void release();
	std::string get_blob();
	int get_bytes();
	double get_double();
	int get_int();
	asINT64 get_int64();
	int get_type();
	std::string get_text();
};
class sqlite3DB {
	int ref_count;
public:
	asIScriptFunction* authorizer;
	std::string authorizer_user_data;
	sqlite3* db;
	sqlite3DB();
	sqlite3DB(const std::string& filename, int mode = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);
	void add_ref();
	void release();
	int close();
	int open(const std::string& filename, int mode = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);
	sqlite3statement* prepare(const std::string& statement, int* statement_tail = NULL);
	int execute(const std::string& statements, CScriptArray* results = NULL);
	asINT64 get_rows_changed();
	asINT64 get_total_rows_changed();
	int limit(int id, int val);
	int set_authorizer(asIScriptFunction* auth, const std::string& user_data = "");
	asINT64 get_last_insert_rowid();
	void set_last_insert_rowid(asINT64 val);
	int get_last_error();
	std::string get_last_error_text();
	bool active() { return db != NULL; }
};

void RegisterSqlite3(asIScriptEngine* engine);
