/* library.cpp - code for the dll call/library object
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <angelscript.h>
#include <obfuscate.h>
#include <scriptarray.h>
#include <scriptdictionary.h>
#include <SDL3/SDL.h>
#include "library.h"
#include "nvgt.h" // g_ScriptEngine, NVGT_SUBSYSTEM_DLLCALL
#include "serialize.h" // g_StringTypeid.
#undef GetObject

void library_message_callback(const asSMessageInfo* msg, void* param) {
	if (!param)
		return;
	std::string* messages = (std::string*)param;
	const char* type = "ERROR: ";
	if (msg->type == asMSGTYPE_WARNING)
		type = "WARNING: ";
	else if (msg->type == asMSGTYPE_INFORMATION)
		type = "INFO: ";
	char buffer[8192];
	snprintf(buffer, 8192, "%s (%d %d): %s: %s\r\n", msg->section, msg->row, msg->col, type, msg->message);
	messages->append(buffer);
}

void library::add_ref() {
	asAtomicInc(ref_count);
}
void library::release() {
	if (asAtomicDec(ref_count) < 1) {
		unload();
		delete this;
	}
}
bool library::load(const std::string& filename) {
	if (engine) return false;
	shared_object = SDL_LoadObject(filename.c_str());
	if (!shared_object) return false;
	engine = asCreateScriptEngine();
	engine->SetMessageCallback(asFUNCTION(library_message_callback), &engine_errors, asCALL_CDECL);
	engine->SetEngineProperty(asEP_ALLOW_UNSAFE_REFERENCES, true);
	ptr_type_id = engine->RegisterObjectType("ptr", sizeof(void*), asOBJ_VALUE | asOBJ_POD);
	return engine != NULL;
}
bool library::unload() {
	if (!engine) return false;
	functions.clear();
	if (shared_object) SDL_UnloadObject(shared_object);
	if (engine) engine->ShutDownAndRelease();
	engine = NULL;
	engine_errors = "";
	shared_object = NULL;
	return true;
}
void library::call(asIScriptGeneric* gen) {
	int tid, prim;
	engine_errors = "";
	if (!engine || !shared_object) {
		gen->SetReturnAddress(NULL);
		return;
	}
	if (!g_StringTypeid) g_StringTypeid = g_ScriptEngine->GetStringFactory();
	asIScriptContext* ACtx = asGetActiveContext();
	std::string* sig = (std::string*)gen->GetArgObject(0);
	asIScriptFunction* func;
	auto it = functions.find(*sig);
	if (it != functions.end()) func = it->second;
	else {
		engine->BeginConfigGroup("parse_decl");
		int id = engine->RegisterGlobalFunction(sig->c_str(), asFUNCTION(NULL), asCALL_CDECL);
		if (id < 0) {
			engine->EndConfigGroup();
			engine->RemoveConfigGroup("parse_decl");
			ACtx->SetException(engine_errors.c_str());
			return;
		}
		engine->EndConfigGroup();
		func = engine->GetFunctionById(id);
		void* addr = (void*)SDL_LoadFunction(shared_object, func->GetName());
		if (!addr) {
			engine->RemoveConfigGroup("parse_decl");
			ACtx->SetException("can't find function");
			return;
		}
		engine->RemoveConfigGroup("parse_decl");
		id = engine->RegisterGlobalFunction(sig->c_str(), asFUNCTION(addr), asCALL_CDECL);
		if (id < 0) {
			ACtx->SetException(engine_errors.c_str());
			return;
		}
		func = engine->GetFunctionById(id);
		functions[*sig] = func;
	}
	asIScriptContext* ctx = engine->CreateContext();
	if (!ctx || ctx->Prepare(func) < 0) {
		gen->SetReturnObject(NULL);
		if (ctx)
		ctx->Release();
		return;
	}
	for (int i = 1; i < gen->GetArgCount() && gen->GetArgTypeId(i) != asTYPEID_VOID; i++) {
		tid = gen->GetArgTypeId(i);
		prim = engine->GetSizeOfPrimitiveType(tid);
		int arg_ret = asERROR;
		if (prim > 0) {
			if (prim == 1) arg_ret = ctx->SetArgByte(i - 1,** (asBYTE**)gen->GetAddressOfArg(i));
			else if (prim == 2) arg_ret = ctx->SetArgWord(i - 1,** (asWORD**)gen->GetAddressOfArg(i));
			else if (tid == asTYPEID_FLOAT) arg_ret = ctx->SetArgFloat(i - 1,** (float**)gen->GetAddressOfArg(i));
			else if (prim == 4) arg_ret = ctx->SetArgDWord(i - 1,** (asDWORD**)gen->GetAddressOfArg(i));
			else if (prim == 8 && tid != asTYPEID_DOUBLE) arg_ret = ctx->SetArgQWord(i - 1,** (asQWORD**)gen->GetAddressOfArg(i));
			else if (prim == 8 && tid == asTYPEID_DOUBLE) arg_ret = ctx->SetArgDouble(i - 1,** (double**)gen->GetAddressOfArg(i));
		} else if (tid == g_StringTypeid) {
			std::string* str = (std::string*)gen->GetArgAddress(i);
			const char* cstr = str->c_str();
			arg_ret = ctx->SetArgObject(i - 1, (void*)&cstr);
		}
		if (arg_ret < 0) {
			char tmp[256];
			if (arg_ret == asERROR)
				snprintf(tmp, 256, "unknown/unsupported type set for argument %d", i);
			else if (arg_ret == asINVALID_TYPE)
				snprintf(tmp, 256, "invalid type set for argument %d", i);
			else if (arg_ret == asINVALID_ARG)
				snprintf(tmp, 256, "trying to pass too many arguments");
			ACtx->SetException(tmp);
			ctx->Release();
			return;
		}
	}
	int xr = ctx->Execute();
	if (xr == asEXECUTION_EXCEPTION) {
		ACtx->SetException(ctx->GetExceptionString());
		ctx->Release();
		return;
	} else if (xr != asEXECUTION_FINISHED) {
		ACtx->SetException("function call failed for an unknown reason");
		ctx->Release();
		return;
	}
	CScriptDictionary* result = CScriptDictionary::Create(g_ScriptEngine);
	gen->SetReturnObject(result);
	tid = func->GetReturnTypeId();
	prim = engine->GetSizeOfPrimitiveType(tid);
	if (prim > 0) result->Set("0", ctx->GetAddressOfReturnValue(), asTYPEID_INT64);
	else if (tid == ptr_type_id) {
		std::string result_str((char*)ctx->GetReturnObject());
		result->Set("0", (void*)&result_str, tid);
	}
}
library* new_script_library() {
	return new library();
}
void library_call_generic(asIScriptGeneric* gen) {
	library* l = (library*)gen->GetObject();
	l->call(gen);
}

std::string string_create_from_pointer(const char* str, size_t length) {
	if (!str) return "";
	if (length == 0) length = strlen(str);
	return std::string(str, length);
}

void RegisterScriptLibrary(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DLLCALL);
	engine->RegisterObjectType(_O("library"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("library"), asBEHAVE_FACTORY, _O("library @l()"), asFUNCTION(new_script_library), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("library"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(library, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("library"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(library, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("bool load(const string&in filename)"), asMETHOD(library, load), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("bool unload()"), asMETHOD(library, unload), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("bool get_active() const property"), asMETHOD(library, is_active), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("dictionary@ call(const string&in signature, ?&in=null, ?&in=null, ?&in=null, ?&in=null, ?&in=null, ?&in=null, ?&in=null, ?&in=null, ?&in=null, ?&in=null)"), asFUNCTION(library_call_generic), asCALL_GENERIC);
	engine->RegisterGlobalFunction("string string_create_from_pointer(uint64 ptr, uint64 length)", asFUNCTION(string_create_from_pointer), asCALL_CDECL);
}
