/* nvgt_sqlite.cpp - sqlite plugin code
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

#include "nvgt_sqlite.h"
#include "pack.h"
// Before this became a plugin it used to support obfuscation of angelscript function signatures, replace the below macro to reenable that.
#define _O(s) s
static asIScriptEngine* g_ScriptEngine = NULL;

std::string stdstr(const char* val, size_t s = 0) {
	if (!val) return "";
	if (s)
		return std::string(val, s);
	return std::string(val);
}

static bool sqlite_started = false;
void init_sqlite() {
	if (sqlite_started) return;
	sqlite3_auto_extension((void(*)(void))sqlite3_eval_init);
	sqlite_started = true;
}

sqlite3statement::sqlite3statement(sqlite3DB* p, sqlite3_stmt* s) : parent(p), statement(s), ref_count(1) {}
void sqlite3statement::add_ref() {
	asAtomicInc(ref_count);
}
void sqlite3statement::release() {
	if (asAtomicDec(ref_count) < 1) {
		sqlite3_finalize(statement);
		delete this;
	}
}
int sqlite3statement::step() { return sqlite3_step(statement); }
int sqlite3statement::reset() { return sqlite3_reset(statement); }
std::string sqlite3statement::get_expanded_sql_statement() { return stdstr(sqlite3_expanded_sql(statement)); }
std::string sqlite3statement::get_sql_statement() { return stdstr(sqlite3_sql(statement)); }
int sqlite3statement::get_column_count() { return sqlite3_column_count(statement); }
int sqlite3statement::get_bind_param_count() { return sqlite3_bind_parameter_count(statement); }
int sqlite3statement::bind_blob(int index, const std::string& val, bool transient) { return sqlite3_bind_blob(statement, index, (void*)&val[0], val.size(), (transient ? SQLITE_TRANSIENT : SQLITE_STATIC)); }
int sqlite3statement::bind_double(int index, double val) { return sqlite3_bind_double(statement, index, val); }
int sqlite3statement::bind_int(int index, int val) { return sqlite3_bind_int(statement, index, val); }
int sqlite3statement::bind_int64(int index, asINT64 val) { return sqlite3_bind_int64(statement, index, val); }
int sqlite3statement::bind_null(int index) { return sqlite3_bind_null(statement, index); }
int sqlite3statement::bind_param_index(const std::string& name) { return sqlite3_bind_parameter_index(statement, name.c_str()); }
std::string sqlite3statement::bind_param_name(int index) { return stdstr(sqlite3_bind_parameter_name(statement, index)); }
int sqlite3statement::bind_text(int index, const std::string& val, bool transient) { return sqlite3_bind_text(statement, index, val.c_str(), val.size(), (transient ? SQLITE_TRANSIENT : SQLITE_STATIC)); }
int sqlite3statement::clear_bindings() { return sqlite3_clear_bindings(statement); }
std::string sqlite3statement::column_blob(int index) { return stdstr((const char*)sqlite3_column_blob(statement, index), column_bytes(index)); }
int sqlite3statement::column_bytes(int index) { return sqlite3_column_bytes(statement, index); }
std::string sqlite3statement::column_decltype(int index) { return stdstr(sqlite3_column_decltype(statement, index)); }
double sqlite3statement::column_double(int index) { return sqlite3_column_double(statement, index); }
int sqlite3statement::column_int(int index) { return sqlite3_column_int(statement, index); }
asINT64 sqlite3statement::column_int64(int index) { return sqlite3_column_int64(statement, index); }
std::string sqlite3statement::column_name(int index) { return stdstr(sqlite3_column_name(statement, index)); }
int sqlite3statement::column_type(int index) { return sqlite3_column_type(statement, index); }
std::string sqlite3statement::column_text(int index) { return stdstr((const char*)sqlite3_column_text(statement, index), column_bytes(index)); }

sqlite3context::sqlite3context(sqlite3_context* ctx) : ref_count(1), c(ctx) {}
void sqlite3context::add_ref() {
	asAtomicInc(ref_count);
}
void sqlite3context::release() {
	if (asAtomicDec(ref_count) < 1)
		delete this;
}
void sqlite3context::set_blob(const std::string& val, bool transient) { sqlite3_result_blob(c, (void*)&val[0], val.size(), (transient ? SQLITE_TRANSIENT : SQLITE_STATIC)); }
void sqlite3context::set_double(double val) { sqlite3_result_double(c, val); }
void sqlite3context::set_error(const std::string& errormsg, int errorcode) { sqlite3_result_error(c, errormsg.c_str(), errormsg.size()); sqlite3_result_error_code(c, errorcode); }
void sqlite3context::set_int(int val) { sqlite3_result_int(c, val); }
void sqlite3context::set_int64(asINT64 val) { sqlite3_result_int64(c, val); }
void sqlite3context::set_null() { sqlite3_result_null(c); }
void sqlite3context::set_text(const std::string& val, bool transient) { sqlite3_result_text(c, val.c_str(), val.size(), (transient ? SQLITE_TRANSIENT : SQLITE_STATIC)); }

sqlite3value::sqlite3value(sqlite3_value* val) : ref_count(1), v(val) {}
void sqlite3value::add_ref() {
	asAtomicInc(ref_count);
}
void sqlite3value::release() {
	if (asAtomicDec(ref_count) < 1)
		delete this;
}
std::string sqlite3value::get_blob() { return stdstr((const char*)sqlite3_value_blob(v), get_bytes()); }
int sqlite3value::get_bytes() { return sqlite3_value_bytes(v); }
double sqlite3value::get_double() { return sqlite3_value_double(v); }
int sqlite3value::get_int() { return sqlite3_value_int(v); }
asINT64 sqlite3value::get_int64() { return sqlite3_value_int64(v); }
int sqlite3value::get_type() { return sqlite3_value_type(v); }
std::string sqlite3value::get_text() { return stdstr((const char*)sqlite3_value_text(v), get_bytes()); }




int sqlite_authorizer_callback(void* user_data, int action, const char* extra1, const char* extra2, const char* extra3, const char* extra4) {
	sqlite3DB* db = (sqlite3DB*)user_data;
	if (!db->authorizer) return SQLITE_ABORT;
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return SQLITE_ABORT;
	if (ctx->Prepare(db->authorizer) < 0) {
		g_ScriptEngine->ReturnContext(ctx);
		return SQLITE_ABORT;
	}
	std::string x1 = (extra1 ? extra1 : ""), x2 = (extra2 ? extra2 : ""), x3 = (extra3 ? extra3 : ""), x4 = (extra4 ? extra4 : "");
	ctx->SetArgObject(0, &db->authorizer_user_data);
	ctx->SetArgDWord(1, action);
	ctx->SetArgObject(2, &x1);
	ctx->SetArgObject(3, &x2);
	ctx->SetArgObject(4, &x3);
	ctx->SetArgObject(5, &x4);
	if (ctx->Execute() != asEXECUTION_FINISHED) {
		g_ScriptEngine->ReturnContext(ctx);
		return SQLITE_ABORT;
	}
	int ret = ctx->GetReturnDWord();
	g_ScriptEngine->ReturnContext(ctx);
	return ret;
}
int sqlite3exec_callback(void* user, int colc, char** colvs, char** colns) {
	if (!user) return SQLITE_OK;
	CScriptArray* array = NULL;
	CScriptArray* parent_array = (CScriptArray*)user;
	parent_array->Resize(parent_array->GetSize() + 1);
	array = ((CScriptArray*)(parent_array->At(parent_array->GetSize() - 1)));
	array->Resize(colc);
	for (int i = 0; i < colc; i++)
		((std::string*)(array->At(i)))->assign(stdstr(colvs[i]));
	return SQLITE_OK;
}
typedef struct {
	asIScriptFunction* func;
	std::string userdata;
} sqlite3func;
void sqlite3func_callback(sqlite3_context* sctx, int argc, sqlite3_value** argv) {
	sqlite3func* f = (sqlite3func*)sqlite3_user_data(sctx);
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) {
		sqlite3_result_error(sctx, "Unable to acquire angelscript context", -1);
		return;
	}
	if (ctx->Prepare(f->func) < 0) {
		sqlite3_result_error(sctx, "Unable to prepare angelscript function", -1);
		return;
	}

}


sqlite3DB::sqlite3DB() : db(NULL), authorizer(NULL), ref_count(1) { init_sqlite(); }
sqlite3DB::sqlite3DB(const std::string& filename, int mode) : db(NULL), authorizer(NULL), ref_count(1) {
	open(filename, mode);
}
void sqlite3DB::add_ref() {
	asAtomicInc(ref_count);
}
void sqlite3DB::release() {
	if (asAtomicDec(ref_count) < 1) {
		if (db) sqlite3_close_v2(db);
		if (authorizer) authorizer->Release();
		delete this;
	}
}
int sqlite3DB::close() {
	int ret = -1;
	if (authorizer) {
		authorizer->Release();
		authorizer = NULL;
	}
	if (db) {
		ret = sqlite3_close(db);
		db = NULL;
	}
	return ret;
}
int sqlite3DB::open(const std::string& filename, int mode) {
	return sqlite3_open_v2(filename.c_str(), &db, mode, NULL);
}
sqlite3statement* sqlite3DB::prepare(const std::string& statement, int* statement_tail) {
	sqlite3_stmt* st = NULL;
	const char* tail = NULL;
	if (!db) return NULL;
	int err = sqlite3_prepare_v2(db, statement.c_str(), statement.size(), &st, &tail);
	if (err != SQLITE_OK) return nullptr;
	sqlite3statement* ret = NULL;
	if (st)
		ret = new sqlite3statement(this, st);
	if (tail && statement_tail)
		*statement_tail = (tail - statement.c_str());
	return ret;
}
int sqlite3DB::execute(const std::string& statements, CScriptArray* results) {
	return sqlite3_exec(db, statements.c_str(), (results ? sqlite3exec_callback : NULL), results, NULL);
}
asINT64 sqlite3DB::get_rows_changed() { return db ? sqlite3_changes(db) : 0; }
asINT64 sqlite3DB::get_total_rows_changed() { return db ? sqlite3_total_changes(db) : 0; }
int sqlite3DB::limit(int id, int val) { return db ? sqlite3_limit(db, id, val) : -1; }
int sqlite3DB::set_authorizer(asIScriptFunction* auth, const std::string& user_data) {
	if (!db) return -1;
	if (authorizer) authorizer->Release();
	authorizer = auth;
	authorizer_user_data = user_data;
	return sqlite3_set_authorizer(db, (auth ? sqlite_authorizer_callback : NULL), this);
}
asINT64 sqlite3DB::get_last_insert_rowid() { return db ? sqlite3_last_insert_rowid(db) : 0; }
void sqlite3DB::set_last_insert_rowid(asINT64 val) { if (db) sqlite3_set_last_insert_rowid(db, val); }
int sqlite3DB::get_last_error() { return db ? sqlite3_errcode(db) : -1; }
std::string sqlite3DB::get_last_error_text() { return db ? stdstr(sqlite3_errmsg(db)) : ""; }

sqlite3DB* new_sqlite3() { return new sqlite3DB(); }
sqlite3DB* new_sqlite3open(const std::string& filename, int mode) { return new sqlite3DB(filename, mode); }

void RegisterSqlite3(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_SQLITE3);
	engine->RegisterObjectType(_O("sqlite3statement"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("sqlite3statement"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(sqlite3statement, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("sqlite3statement"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(sqlite3statement, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int step()"), asMETHOD(sqlite3statement, step), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int reset()"), asMETHOD(sqlite3statement, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string get_expanded_sql_statement() property"), asMETHOD(sqlite3statement, get_expanded_sql_statement), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string get_sql_statement() property"), asMETHOD(sqlite3statement, get_sql_statement), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int get_bind_param_count() property"), asMETHOD(sqlite3statement, get_bind_param_count), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int get_column_count() property"), asMETHOD(sqlite3statement, get_column_count), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_blob(int, const string&in, bool=true)"), asMETHOD(sqlite3statement, bind_blob), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_double(int, double)"), asMETHOD(sqlite3statement, bind_double), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_int(int, int)"), asMETHOD(sqlite3statement, bind_int), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_int64(int, int64)"), asMETHOD(sqlite3statement, bind_int64), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_null(int)"), asMETHOD(sqlite3statement, bind_null), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_param_index(const string&in)"), asMETHOD(sqlite3statement, bind_param_index), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string bind_param_name(int)"), asMETHOD(sqlite3statement, bind_param_name), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int bind_text(int, const string&in, bool=true)"), asMETHOD(sqlite3statement, bind_text), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int clear_bindings()"), asMETHOD(sqlite3statement, clear_bindings), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string column_blob(int)"), asMETHOD(sqlite3statement, column_blob), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int column_bytes(int)"), asMETHOD(sqlite3statement, column_bytes), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string column_decltype(int)"), asMETHOD(sqlite3statement, column_decltype), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("double column_double(int)"), asMETHOD(sqlite3statement, column_double), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int column_int(int)"), asMETHOD(sqlite3statement, column_int), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int64 column_int64(int)"), asMETHOD(sqlite3statement, column_int64), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string column_name(int)"), asMETHOD(sqlite3statement, column_name), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("int column_type(int)"), asMETHOD(sqlite3statement, column_type), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3statement"), _O("string column_text(int)"), asMETHOD(sqlite3statement, column_text), asCALL_THISCALL);
	engine->RegisterFuncdef(_O("int sqlite3authorizer(string, int, string, string, string, string)"));
	engine->RegisterObjectType(_O("sqlite3"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("sqlite3"), asBEHAVE_FACTORY, _O("sqlite3@ db()"), asFUNCTION(new_sqlite3), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("sqlite3"), asBEHAVE_FACTORY, _O("sqlite3@ db(const string&in, int=6)"), asFUNCTION(new_sqlite3open), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("sqlite3"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(sqlite3DB, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("sqlite3"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(sqlite3DB, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int close()"), asMETHOD(sqlite3DB, close), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int open(const string&in, int=6)"), asMETHOD(sqlite3DB, open), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("sqlite3statement@ prepare(const string&in, int&out=void)"), asMETHOD(sqlite3DB, prepare), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int execute(const string&in, string[][]@=null)"), asMETHOD(sqlite3DB, execute), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int64 get_rows_changed() property"), asMETHOD(sqlite3DB, get_rows_changed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int64 get_total_rows_changed() property"), asMETHOD(sqlite3DB, get_total_rows_changed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int limit(int id, int val)"), asMETHOD(sqlite3DB, limit), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int set_authorizer(sqlite3authorizer@, const string&in=\"\")"), asMETHOD(sqlite3DB, set_authorizer), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int64 get_last_insert_rowid() property"), asMETHOD(sqlite3DB, get_last_insert_rowid), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("void set_last_insert_rowid(int64) property"), asMETHOD(sqlite3DB, set_last_insert_rowid), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("int get_last_error()"), asMETHOD(sqlite3DB, get_last_error), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("string get_last_error_text()"), asMETHOD(sqlite3DB, get_last_error_text), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("sqlite3"), _O("bool get_active() property"), asMETHOD(sqlite3DB, active), asCALL_THISCALL);
}

plugin_main(nvgt_plugin_shared* shared) {
	prepare_plugin(shared);
	if (const auto rc = sqlite3_initialize(); rc != SQLITE_OK) {
		return false;
	}
	g_ScriptEngine = shared->script_engine;
	RegisterSqlite3(shared->script_engine);
	RegisterScriptPack(shared->script_engine);
	return true;
}
