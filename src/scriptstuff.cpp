/* scriptstuff.cpp - angelscript subscripting implementation code and various scripting related routines
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

#define NOMINMAX
#include <algorithm>
#include <chrono>
#include <cstring>
#include <map>
#include <vector>
#ifdef _WIN32
	#include <windows.h>
#endif
#include <obfuscate.h>
#include <Poco/Util/Application.h>
#include <Poco/Exception.h>
#include <Poco/Format.h>
#include <Poco/Thread.h>
#include <scriptany.h>
#include <scriptarray.h>
#include <scriptdictionary.h>
#include <scripthelper.h>
#include "datastreams.h"
#include "nvgt.h"
#include "scriptstuff.h"
#include "timestuff.h"

// The seemingly pointless few lines of code that follow are just a bit of structure that can be used to aid in some types of debugging if needed. Extra code can be added temporarily in the line callback that sets any needed info in the g_DebugInfo string which can easily be read by a c debugger.
std::string g_DebugInfo;
void debug_callback(asIScriptContext* ctx, void* obj) {
}

int g_GCMode = 2;
Poco::Thread* g_GCThread = nullptr;
asQWORD g_GCAutoFullTime = ticks();
DWORD g_GCAutoFrequency = 300000;
void garbage_collect(bool full = true) {
	if (!full && g_GCMode < 3)
		g_ScriptEngine->GarbageCollect(asGC_ONE_STEP | asGC_DETECT_GARBAGE);
	else if (full && g_GCMode < 3)
		g_ScriptEngine->GarbageCollect(asGC_FULL_CYCLE);
	else if (full && g_GCMode == 3)
		g_GCAutoFullTime = 0;
}
void garbage_collect_action() {
	g_ScriptEngine->GarbageCollect(asGC_ONE_STEP);
	if (ticks() - g_GCAutoFullTime > g_GCAutoFrequency) {
		g_ScriptEngine->GarbageCollect(asGC_ONE_STEP);
		g_GCAutoFullTime = ticks();
	}
}
void garbage_collect_thread(void* user) {
	Poco::Thread::sleep(10);
	while (g_GCMode == 3) {
		Poco::Thread::sleep(5);
		garbage_collect_action();
	}
	delete g_GCThread;
	g_GCThread = nullptr;
}
int get_garbage_collect_mode() {
	return g_GCMode;
}
bool set_garbage_collect_mode(int m) {
	if (m < 1 || m > 3) return false;
	if (m == 3 && !g_GCThread) {
		g_GCThread = new Poco::Thread;
		if (!g_GCThread)
			return false;
		g_GCThread->start(garbage_collect_thread);
	}
	g_GCMode = m;
	return true;
}
DWORD get_garbage_collect_auto_frequency() {
	return g_GCAutoFrequency;
}
bool set_garbage_collect_auto_frequency(DWORD freq) {
	if (freq < 2000 || freq > 86400000) return false;
	g_GCAutoFrequency = freq;
	return true;
}

std::map<asIScriptFunction*, std::chrono::high_resolution_clock::time_point> profiler_cache;
bool is_profiling;
std::chrono::high_resolution_clock::time_point profiler_ticks;
std::chrono::high_resolution_clock::time_point profiler_start = std::chrono::high_resolution_clock::now();
asIScriptFunction* profiler_last_func;
int profiler_current_line = 0;
const char* profiler_current_section = NULL;

void profiler_callback(asIScriptContext* ctx, void* obj) {
	if (!is_profiling) return;
	int col;
	profiler_current_line = ctx->GetLineNumber(0, &col, &profiler_current_section);
	/*
	const char* section;
	int line, col;
	line=ctx->GetLineNumber(0, &col, &section);
	char tmp[MAX_PATH];
	snprintf(tmp, MAX_PATH, "%s %d\r\n", section, line);
	FILE* f=fopen("debug.txt", "ab");
	fputs(tmp, f);
	fclose(f);
	*/
	auto t = std::chrono::high_resolution_clock::now();
	asIScriptFunction* sfunc = ctx->GetSystemFunction();
	asIScriptFunction* func = (sfunc != NULL ? sfunc : ctx->GetFunction());
	auto elapsed = t - profiler_ticks;
	profiler_ticks = t;
	if (func == profiler_last_func) {
		profiler_cache[func] += elapsed;;
		return;
	}
	if (profiler_last_func != NULL) {
		std::map<asIScriptFunction*, std::chrono::high_resolution_clock::time_point>::iterator it = profiler_cache.find(func);
		if (it == profiler_cache.end())
			profiler_cache[func] = std::chrono::high_resolution_clock::time_point(profiler_start + elapsed);
		else
			profiler_cache[func] += elapsed;
	}
	profiler_last_func = func;
}
void reset_profiler() {
	profiler_cache.clear();
	profiler_ticks = std::chrono::high_resolution_clock::now();
	profiler_start = std::chrono::high_resolution_clock::now();
	profiler_last_func = NULL;
	prepare_profiler();
}
void prepare_profiler() {
	if (!is_profiling) return;
	asIScriptContext* ctx = asGetActiveContext();
	if (!ctx) return;
	profiler_last_func = ctx->GetFunction();
	profiler_cache[profiler_last_func] = profiler_start;
}
void start_profiling() {
	if (is_profiling) return;
	asIScriptContext* ctx = asGetActiveContext();
	if (!ctx) return;
	is_profiling = true;
	reset_profiler();
}
void stop_profiling() {
	asIScriptContext* ctx = asGetActiveContext();
	if (!is_profiling || !ctx)
		return;
	is_profiling = false;
}
static BOOL profiler_results_sort(asIScriptFunction* f1, asIScriptFunction* f2) {
	return profiler_cache[f1] > profiler_cache[f2];
}
std::string generate_profile(bool reset = true) {
	if (profiler_cache.size() < 1) return "";
	std::vector<asIScriptFunction*> results;
	results.reserve(profiler_cache.size());
	for (auto const& i : profiler_cache)
		results.push_back(i.first);
	std::sort(results.begin(), results.end(), profiler_results_sort);
	int size = results.size();
	char tmp[128];
	unsigned int total_ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::high_resolution_clock::now() - profiler_start).count();
	int r = snprintf(tmp, 128, "total functions called: %d\r\ntotal execution time: %ums\r\n\r\n", size, total_ms);
	tmp[r] = 0;
	std::string output(tmp);
	for (int i = 0; i < size; i++) {
		char text[4096];
		const char* decl = results[i]->GetDeclaration(true, true, true);
		float ms = std::chrono::duration_cast<std::chrono::milliseconds>(profiler_cache[results[i]] - profiler_start).count();
		float p = (ms / total_ms) * 100.0;
		int r = snprintf(text, 4096, "%s: %.0fms (%.3f%%)\r\n", decl, ms, p);
		text[r] = 0;
		output += text;
	}
	if (reset) reset_profiler();
	return output;
}

std::string get_call_stack_ctx(asIScriptContext* ctx) {
	asUINT size = ctx->GetCallstackSize();
	char tmp[4096];
	snprintf(tmp, 4096, "Call stack size: %d\r\n\r\n", size);
	std::string stack = tmp;
	for (asUINT i = 0; i < size; i++) {
		const char* section;
		int line, col;
		asIScriptFunction* func = ctx->GetFunction(i);
		line = ctx->GetLineNumber(i, &col, &section);
		snprintf(tmp, 4096, "Function: %s\r\nFile: %s\r\n", func->GetDeclaration(), section);
		stack += tmp;
		if (line) {
			snprintf(tmp, 4096, "Line: %d (%d)\r\n", line, col);
			stack += tmp;
		}
		stack += "\r\n";
	}
	return stack;
}
std::string get_call_stack() {
	return get_call_stack_ctx(asGetActiveContext());
}
int get_call_stack_size() {
	asIScriptContext* ctx = asGetActiveContext();
	return ctx->GetCallstackSize();
}
std::string get_script_current_function() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptFunction* func = ctx->GetFunction();
	if (!func)
		return "";
	return func->GetDeclaration();
}
std::string get_script_current_file() {
	asIScriptContext* ctx = asGetActiveContext();
	const char* section = NULL;
	ctx->GetLineNumber(0, NULL, &section);
	if (section) return std::string(section);
	return "";
}
int get_script_current_line() {
	asIScriptContext* ctx = asGetActiveContext();
	return ctx->GetLineNumber();
}
std::string get_script_executable() {
	return Poco::Util::Application::instance().config().getString("application.path");
}
std::string get_script_path() {
	return g_scriptpath;
}
std::string get_function_signature(void* function, int type_id) {
	asIScriptContext* ctx = asGetActiveContext();
	if (!ctx) return "";
	asIScriptEngine* engine = ctx ? ctx->GetEngine() : g_ScriptEngine;
	asITypeInfo* t = engine->GetTypeInfoById(type_id);
	asIScriptFunction* sig = t->GetFuncdefSignature();
	if (!sig) {
		ctx->SetException("not a function");
		return "";
	}
	if (type_id & asTYPEID_OBJHANDLE)
		return (*(asIScriptFunction**)function)->GetDeclaration();
	else
		return sig->GetDeclaration();
}
bool script_compiled() {
	#ifdef NVGT_STUB
	return true;
	#else
	return false;
	#endif
}
void dump_angelscript_engine_configuration(datastream* output) {
	#ifndef NVGT_STUB
	if (!output || !output->get_ostr()) return;
	WriteConfigToStream(g_ScriptEngine, *output->get_ostr());
	#endif
}
void script_assert(bool expr, const std::string& failtext = "") {
	if (!expr) throw Poco::AssertionViolationException(failtext);
}

void script_message_callback(const asSMessageInfo* msg, void* param) {
	if (!param)
		return;
	CScriptArray* messages = (CScriptArray*)param;
	const char* type = "ERROR: ";
	if (msg->type == asMSGTYPE_WARNING)
		type = "WARNING: ";
	else if (msg->type == asMSGTYPE_INFORMATION)
		type = "INFO: ";
	char buffer[8192];
	snprintf(buffer, 8192, "file: %s\r\nline: %d (%d)\r\n%s: %s\r\n\r\n", msg->section, msg->row, msg->col, type, msg->message);
	std::string buffer_str = buffer; // Damn it g++
	if (msg->type == asMSGTYPE_ERROR)
		messages->InsertLast(&buffer_str);
}
struct script_function_call_data {
	int max_statement_count;
	int current_statement_count;
};
void script_function_line_callback(asIScriptContext* ctx, script_function_call_data* data);
CScriptDictionary* script_function_call(asIScriptFunction* func, CScriptDictionary* args, CScriptArray* errors = NULL, int max_statement_count = 0) {
	std::string failure_reason = "";
	std::string callstack1 = "";
	std::string callstack2 = "";
	g_ScriptEngine->SetMessageCallback(asFUNCTION(script_message_callback), errors, asCALL_CDECL);
	script_function_call_data call_data {max_statement_count, 0};
	asIScriptContext* ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext* ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
	if (!ctx) {
		failure_reason = "ERROR: Failed to acquire context.";
		goto failure;
	}
	if (ctx->Prepare(func) < 0) {
		failure_reason = "ERROR: Failed to prepare context.";
		goto failure;
	}
	int arg_index;
	arg_index = 1;
	while (args && args->GetSize() > 0) {
		int arg_type_id;
		DWORD arg_tmods;
		CScriptDictionary::CIterator k = args->find(std::to_string(arg_index));
		if (k == args->end()) break;
		if (func->GetParam(arg_index - 1, &arg_type_id, &arg_tmods) < 0) {
			/*
			failure_reason="ERROR: Trying to pass too many arguments.";
			goto failure;
			*/
			break;
		}
		void* arg_value = ctx->GetAddressOfArg(arg_index - 1);
		if (!arg_value) {
			failure_reason = "ERROR: Trying to pass too many arguments.";
			goto failure;
		}
		if ((arg_type_id & asTYPEID_MASK_OBJECT)) {
			const void* o = k.GetAddressOfValue();
			if (arg_type_id & asTYPEID_OBJHANDLE)
				ctx->SetArgObject(arg_index - 1, *(void**)o);
			else
				ctx->SetArgObject(arg_index - 1, (void*)o);
		} else if (!k.GetValue(arg_value, arg_type_id)) {
			if (arg_type_id & asTYPEID_INT32) {
				asINT64 val;
				k.GetValue(val);
				ctx->SetArgDWord(arg_index - 1, val);
			} else if (arg_type_id & asTYPEID_FLOAT) {
				double val;
				k.GetValue(val);
				ctx->SetArgFloat(arg_index - 1, val);
			} else if (arg_type_id & asTYPEID_BOOL) {
				asINT64 val;
				k.GetValue(val);
				ctx->SetArgByte(arg_index - 1, val);
			} else {
				failure_reason = "ERROR: Type mismatch for parameter ";
				failure_reason += std::to_string(arg_index);
				goto failure;
			}
		}
		arg_index += 1;
	}
	call_data.current_statement_count = 0;
	ctx->SetLineCallback(asFUNCTION(script_function_line_callback), &call_data, asCALL_CDECL);
	int xr;
	xr = ctx->Execute();
	ctx->SetLineCallback(asFUNCTION(profiler_callback), NULL, asCALL_CDECL);
	if (xr != asEXECUTION_FINISHED) {
		if (xr == asEXECUTION_EXCEPTION) {
			char msg[4096];
			const char* section;
			int col;
			const char* decl = ctx->GetExceptionFunction()->GetDeclaration();
			const char* exc = ctx->GetExceptionString();
			int line = ctx->GetExceptionLineNumber(&col, &section);
			snprintf(msg, 4096, "Exception: %s in %s %s at line %d, %d", exc, section, decl, line, col);
			failure_reason = msg;
		} else if (xr == asEXECUTION_SUSPENDED) {
			char msg[128];
			snprintf(msg, 128, "maximum statement count of %d exceeded", call_data.max_statement_count);
			failure_reason = msg;
		}
		callstack1 = get_call_stack_ctx(ctx);
		if (ctx != ACtx)
			callstack2 = get_call_stack_ctx(ACtx);
		goto failure;
	}
	if (args)
		args->DeleteAll();
	int ret_type_id;
	ret_type_id = func->GetReturnTypeId();
	if (ret_type_id != asTYPEID_VOID) {
		void* ret = ctx->GetAddressOfReturnValue();
		if (ret && !args)
			args = CScriptDictionary::Create(g_ScriptEngine);
		if (args && ret)
			args->Set("0", ret, ret_type_id);
	}
	if (new_context) g_ScriptEngine->ReturnContext(ctx);
	else ctx->PopState();
	g_ScriptEngine->ClearMessageCallback();
	if (errors)
		errors->Release();
	return args;
failure:
	if (errors != NULL && failure_reason != "") {
		errors->InsertLast(&failure_reason);
		errors->InsertLast(&callstack1);
		errors->InsertLast(&callstack2);
	}
	if (ctx) {
		if (new_context) {
			ctx->Unprepare();
			g_ScriptEngine->ReturnContext(ctx);
		} else ctx->PopState();
	}
	if (args) {
		args->DeleteAll();
		args->Release();
		args = NULL;
	}
	g_ScriptEngine->ClearMessageCallback();
	if (errors)
		errors->Release();
	return NULL;
}
bool script_function_retrieve(asIScriptFunction* func, asIScriptFunction** out_func, int type_id) {
	if (type_id & asTYPEID_OBJHANDLE) {
		*out_func = func;
		func->AddRef();
		return true;
	}
	return false;
}
int script_function_get_line(asIScriptFunction* func) {
	asIScriptContext* ctx = g_ScriptEngine->CreateContext();
	if (!ctx) return -2;
	if (ctx->Prepare(func) < 0) return -3;
	int ret = ctx->GetLineNumber();
	ctx->Release();
	return ret;
}
std::string script_function_get_decl(asIScriptFunction* func, bool include_object_name = true, bool include_namespace = true, bool include_param_names = false) {
	return std::string(func->GetDeclaration(include_object_name, include_namespace, include_param_names));
}
std::string script_function_get_decl_property(asIScriptFunction* func) { return script_function_get_decl(func); }
std::string script_function_get_name(asIScriptFunction* func) {
	return std::string(func->GetName());
}
std::string script_function_get_namespace(asIScriptFunction* func) {
	return std::string(func->GetNamespace());
}
std::string script_function_get_script(asIScriptFunction* func, int* row, int* col) {
	const char* script;
	if (func->GetDeclaredAt(&script, row, col) < 0) return "";
	return std::string(script);
}
void script_function_line_callback(asIScriptContext* ctx, script_function_call_data* data) {
	profiler_callback(ctx, NULL);
	if (data->max_statement_count < 1) return;
	data->current_statement_count += 1;
	if (data->current_statement_count > data->max_statement_count)
		ctx->Suspend();
	return;
}
class script_module_bytecode_stream : public asIBinaryStream {
	std::string data;
	int cursor;
public:
	script_module_bytecode_stream(const std::string& code = "") : data(code), cursor(0) {}
	void set(const std::string& code) {
		data = code;
		cursor = 0;
	}
	std::string get() {
		return data;
	}
	int Write(const void* ptr, asUINT size) {
		data.append((char*)ptr, size);
		return size;
	}
	int Read(void* ptr, asUINT size) {
		if (cursor >= data.size()) return -1;
		memcpy(ptr, &data[cursor], size);
		cursor += size;
		return size;
	}
};
class script_module {
	asIScriptModule* mod;
	int RefCount;
	BOOL exists;
public:
	unsigned int max_statement_count;
	script_module(asIScriptModule* module, BOOL e) {
		mod = module;
		exists = e;
		RefCount = 1;
		max_statement_count = 0;
	}
	void AddRef() {
		asAtomicInc(RefCount);
	}
	void Release() {
		if (asAtomicDec(RefCount) < 1)
			delete this;
	}
	int add_section(const std::string& name, const std::string& code, int line_offset = 0) {
		if (mod == NULL)
			return asNO_MODULE;
		return mod->AddScriptSection(name.c_str(), code.c_str(), code.size(), line_offset);
	}
	int build(CScriptArray* errors) {
		if (mod == NULL)
			return asNO_MODULE;
		g_ScriptEngine->SetMessageCallback(asFUNCTION(script_message_callback), errors, asCALL_CDECL);
		int result = mod->Build();
		g_ScriptEngine->ClearMessageCallback();
		if (errors)
			errors->Release();
		return result;
	}
	std::string get_bytecode(bool release) {
		if (mod == NULL) return "";
		script_module_bytecode_stream b;
		if (mod->SaveByteCode(&b, release) < 0) return "";
		return b.get();
	}
	int set_bytecode(const std::string& code, bool* release = NULL, CScriptArray* errors = NULL) {
		if (mod == NULL) {
			if (errors)
				errors->Release();
			return asNO_MODULE;
		}
		g_ScriptEngine->SetMessageCallback(asFUNCTION(script_message_callback), errors, asCALL_CDECL);
		script_module_bytecode_stream b(code);
		int ret = mod->LoadByteCode(&b, release);
		g_ScriptEngine->ClearMessageCallback();
		return ret;
	}
	int reset_globals(CScriptArray* errors) {
		if (mod == NULL) {
			if (errors)
				errors->Release();
			return asNO_MODULE;
		}
		g_ScriptEngine->SetMessageCallback(asFUNCTION(script_message_callback), errors, asCALL_CDECL);
		asIScriptContext* ctx = g_ScriptEngine->RequestContext();
		if (!ctx) {
			std::string err = "ERROR: failed to acquire context";
			if (errors)
				errors->InsertLast(&err);
			g_ScriptEngine->ClearMessageCallback();
			if (errors)
				errors->Release();
			return asERROR;
		}
		int result = mod->ResetGlobalVars(ctx);
		g_ScriptEngine->ClearMessageCallback();
		if (ctx) {
			ctx->Unprepare();
			g_ScriptEngine->ReturnContext(ctx);
		}
		if (errors)
			errors->Release();
		return result;
	}
	int bind_all_imported_functions() {
		if (!mod)
			return asNO_MODULE;
		return mod->BindAllImportedFunctions();
	}
	int bind_imported_function(DWORD index, asIScriptFunction* func) {
		if (!mod)
			return asNO_MODULE;
		if (!func)
			return asNO_FUNCTION;
		return mod->BindImportedFunction(index, func);
	}
	asIScriptFunction* compile_function(const std::string& section_name, const std::string& code, CScriptArray* errors, BOOL add_to_module = FALSE, DWORD line_offset = 0) {
		if (mod == NULL) {
			if (errors) errors->Release();
			return NULL;
		}
		g_ScriptEngine->SetMessageCallback(asFUNCTION(script_message_callback), errors, asCALL_CDECL);
		asIScriptFunction* out_ptr;
		int result = mod->CompileFunction(section_name.c_str(), code.c_str(), line_offset, (add_to_module ? asCOMP_ADD_TO_MODULE : 0), &out_ptr);
		g_ScriptEngine->ClearMessageCallback();
		if (result < 0) {
			if (errors) errors->Release();
			return NULL;
		}
		if (errors) errors->Release();
		return out_ptr;
	}
	int compile_global(const std::string& section_name, const std::string& code, CScriptArray* errors, DWORD line_offset = 0) {
		if (mod == NULL) {
			if (errors) errors->Release();
			return asNO_MODULE;
		}
		g_ScriptEngine->SetMessageCallback(asFUNCTION(script_message_callback), errors, asCALL_CDECL);
		int result = mod->CompileGlobalVar(section_name.c_str(), code.c_str(), line_offset);
		g_ScriptEngine->ClearMessageCallback();
		if (errors) errors->Release();
		return result;
	}
	void discard() {
		if (!mod) return;
		mod->Discard();
	}
	DWORD get_function_count() {
		if (!mod) return 0;
		return mod->GetFunctionCount();
	}
	DWORD get_global_count() {
		if (!mod) return 0;
		return mod->GetGlobalVarCount();
	}
	DWORD get_imported_function_count() {
		if (!mod) return 0;
		return mod->GetImportedFunctionCount();
	}
	DWORD set_access_mask(DWORD mask) {
		if (!mod) return 0;
		return mod->SetAccessMask(mask);
	}
	asIScriptFunction* get_function_by_index(int index) {
		if (!mod) return NULL;
		return mod->GetFunctionByIndex(index);
	}
	asIScriptFunction* get_function_by_name(const std::string& name) {
		if (!mod) return NULL;
		return mod->GetFunctionByName(name.c_str());
	}
	asIScriptFunction* get_function_by_decl(const std::string& name) {
		if (!mod) return NULL;
		return mod->GetFunctionByDecl(name.c_str());
	}
	const std::string get_imported_function_decl(DWORD index) {
		if (!mod)
			return "";
		const char* result = mod->GetImportedFunctionDeclaration(index);
		if (!result) return "";
		return std::string(result);
	}
	int get_imported_function_index(const std::string& decl) {
		if (!mod)
			return asNO_MODULE;
		return mod->GetImportedFunctionIndexByDecl(decl.c_str());
	}
	const std::string get_imported_function_module(DWORD index) {
		if (!mod)
			return "";
		const char* result = mod->GetImportedFunctionSourceModule(index);
		if (!result) return "";
		return std::string(result);
	}
	CScriptAny* get_global(DWORD index) {
		if (!mod)
			return NULL;
		const char* name;
		int type_id;
		if (mod->GetGlobalVar(index, &name, NULL, &type_id) < 0)
			return NULL;
		void* ref = mod->GetAddressOfGlobalVar(index);
		if (!ref) return NULL;
		return new CScriptAny(ref, type_id, g_ScriptEngine);
	}
	const std::string get_global_decl(DWORD index) {
		if (!mod)
			return "";
		const char* result = mod->GetGlobalVarDeclaration(index);
		if (!result) return "";
		return std::string(result);
	}
	int get_global_index_by_decl(const std::string& decl) {
		if (!mod)
			return asNO_MODULE;
		return mod->GetGlobalVarIndexByDecl(decl.c_str());
	}
	int get_global_index_by_name(const std::string& decl) {
		if (!mod)
			return asNO_MODULE;
		return mod->GetGlobalVarIndexByName(decl.c_str());
	}
	const std::string get_global_name(DWORD index) {
		if (!mod)
			return "";
		const char* result;
		if (mod->GetGlobalVar(index, &result) < 0) return "";
		if (!result) return "";
		return std::string(result);
	}
	const std::string get_name() {
		if (!mod)
			return "";
		const char* result = mod->GetName();
		if (!result) return "";
		return std::string(result);
	}
	void set_name(const std::string& name) {
		if (!mod) return;
		mod->SetName(name.c_str());
	}
};
script_module* script_get_module(const std::string& name, int mode) {
	BOOL exists = FALSE;
	if (mode != asGM_ALWAYS_CREATE)
		exists = g_ScriptEngine->GetModule(name.c_str(), asGM_ONLY_IF_EXISTS) != NULL;
	asIScriptModule* mod = g_ScriptEngine->GetModule(name.c_str(), (asEGMFlags)mode);
	if (!mod) return NULL;
	return new script_module(mod, exists);
}
void RegisterScripting(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_SCRIPTING);
	engine->RegisterObjectType(_O("script_function"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("script_function"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(asIScriptFunction, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("script_function"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(asIScriptFunction, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("dictionary@ call(dictionary@ args, string[]@ errors = null, int max_statement_count = 0)"), asFUNCTION(script_function_call), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("dictionary@ opCall(dictionary@ args, string[]@ errors = null, int max_statement_count = 0)"), asFUNCTION(script_function_call), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool retrieve(?&out)"), asFUNCTION(script_function_retrieve), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("string get_decl(bool include_object_name, bool include_namespace = true, bool include_param_names = true)"), asFUNCTION(script_function_get_decl), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("string get_decl() property"), asFUNCTION(script_function_get_decl_property), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("string get_name() property"), asFUNCTION(script_function_get_name), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("string get_namespace() property"), asFUNCTION(script_function_get_namespace), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("string get_script() property"), asFUNCTION(script_function_get_script), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("int get_line() property"), asFUNCTION(script_function_get_line), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_explicit() property"), asMETHOD(asIScriptFunction, IsExplicit), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_final() property"), asMETHOD(asIScriptFunction, IsFinal), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_override() property"), asMETHOD(asIScriptFunction, IsOverride), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_private() property"), asMETHOD(asIScriptFunction, IsPrivate), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_property() property"), asMETHOD(asIScriptFunction, IsProperty), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_protected() property"), asMETHOD(asIScriptFunction, IsProtected), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_read_only() property"), asMETHOD(asIScriptFunction, IsReadOnly), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_function"), _O("bool get_is_shared() property"), asMETHOD(asIScriptFunction, IsShared), asCALL_THISCALL);
	engine->RegisterObjectType(_O("script_module"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("script_module"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(script_module, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("script_module"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(script_module, Release), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("script_module"), _O("uint max_statement_count"), asOFFSET(script_module, max_statement_count));
	engine->RegisterObjectMethod(_O("script_module"), _O("int add_section(const string&in, const string&in, uint=0)"), asMETHOD(script_module, add_section), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int build(string[]@=null)"), asMETHOD(script_module, build), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("string get_bytecode(bool)"), asMETHOD(script_module, get_bytecode), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int set_bytecode(const string&in, bool&out, string[]@=null)"), asMETHOD(script_module, set_bytecode), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int reset_globals(string[]@=null)"), asMETHOD(script_module, reset_globals), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int bind_all_imported_functions()"), asMETHOD(script_module, bind_all_imported_functions), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int bind_imported_function(uint, script_function@)"), asMETHOD(script_module, bind_imported_function), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int compile_global(const string&in, const string&in, uint=0)"), asMETHOD(script_module, compile_global), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("script_function@ compile_function(const string&in, const string&in, string[]@=null, bool=false, uint=0)"), asMETHOD(script_module, compile_function), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("void discard()"), asMETHOD(script_module, discard), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("script_function@+ get_function_by_decl(const string&in)"), asMETHOD(script_module, get_function_by_decl), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("script_function@+ get_function_by_index(uint)"), asMETHOD(script_module, get_function_by_index), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("script_function@+ get_function_by_name(const string&in)"), asMETHOD(script_module, get_function_by_name), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("any@ get_global(uint)"), asMETHOD(script_module, get_global), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("const string get_global_decl(uint)"), asMETHOD(script_module, get_global_decl), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int get_global_index_by_decl(const string&in)"), asMETHOD(script_module, get_global_index_by_decl), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int get_global_index_by_name(const string&in)"), asMETHOD(script_module, get_global_index_by_name), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("const string get_global_name(uint)"), asMETHOD(script_module, get_global_name), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("uint get_function_count()"), asMETHOD(script_module, get_function_count), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("uint get_global_count()"), asMETHOD(script_module, get_global_count), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("uint get_imported_function_count()"), asMETHOD(script_module, get_imported_function_count), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("uint set_access_mask(uint)"), asMETHOD(script_module, set_access_mask), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("const string get_imported_function_decl(uint)"), asMETHOD(script_module, get_imported_function_decl), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("int get_imported_function_index(const string&in)"), asMETHOD(script_module, get_imported_function_index), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("const string get_imported_function_module(uint)"), asMETHOD(script_module, get_imported_function_module), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("string get_name() property"), asMETHOD(script_module, get_name), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("script_module"), _O("void set_name(const string&in) property"), asMETHOD(script_module, set_name), asCALL_THISCALL);
	engine->RegisterGlobalFunction(_O("script_module@ script_get_module(const string&in, int=1)"), asFUNCTION(script_get_module), asCALL_CDECL);
}
void RegisterScriptstuff(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UNCLASSIFIED);
	engine->RegisterGlobalProperty("const bool profiler_is_running", &is_profiling);
	engine->RegisterGlobalFunction("int get_garbage_collect_mode() property", asFUNCTION(get_garbage_collect_mode), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_garbage_collect_mode(int) property", asFUNCTION(set_garbage_collect_mode), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_garbage_collect_auto_frequency() property", asFUNCTION(get_garbage_collect_auto_frequency), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_garbage_collect_auto_frequency(int) property", asFUNCTION(set_garbage_collect_auto_frequency), asCALL_CDECL);
	engine->RegisterGlobalFunction("void garbage_collect(bool = true)", asFUNCTION(garbage_collect), asCALL_CDECL);
	engine->RegisterGlobalFunction("void start_profiling()", asFUNCTION(start_profiling), asCALL_CDECL);
	engine->RegisterGlobalFunction("void stop_profiling()", asFUNCTION(stop_profiling), asCALL_CDECL);
	engine->RegisterGlobalFunction("void reset_profiler()", asFUNCTION(reset_profiler), asCALL_CDECL);
	engine->RegisterGlobalFunction("string generate_profile(bool = true)", asFUNCTION(generate_profile), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterGlobalFunction("string get_call_stack() property", asFUNCTION(get_call_stack), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_call_stack_size() property", asFUNCTION(get_call_stack_size), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_SCRIPT_CURRENT_FUNCTION() property", asFUNCTION(get_script_current_function), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_SCRIPT_CURRENT_FILE() property", asFUNCTION(get_script_current_file), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_SCRIPT_CURRENT_LINE() property", asFUNCTION(get_script_current_line), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_SCRIPT_MAIN_PATH() property", asFUNCTION(get_script_path), asCALL_CDECL);
	engine->RegisterGlobalFunction("void assert(bool, const string&in = \"\")", asFUNCTION(script_assert), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UNCLASSIFIED);
	engine->RegisterGlobalFunction("string get_SCRIPT_EXECUTABLE() property", asFUNCTION(get_script_executable), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_SCRIPT_COMPILED() property", asFUNCTION(script_compiled), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_function_signature(?&in)", asFUNCTION(get_function_signature), asCALL_CDECL);
	engine->RegisterGlobalFunction("void acquire_exclusive_lock()", asFUNCTION(asAcquireExclusiveLock), asCALL_CDECL);
	engine->RegisterGlobalFunction("void release_exclusive_lock()", asFUNCTION(asReleaseExclusiveLock), asCALL_CDECL);
	engine->RegisterGlobalFunction("void acquire_shared_lock()", asFUNCTION(asAcquireSharedLock), asCALL_CDECL);
	engine->RegisterGlobalFunction("void release_shared_lock()", asFUNCTION(asReleaseSharedLock), asCALL_CDECL);
	engine->RegisterGlobalFunction("void script_dump_engine_configuration(datastream@+)", asFUNCTION(dump_angelscript_engine_configuration), asCALL_CDECL);
	RegisterScripting(engine);
}
