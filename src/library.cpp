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
#include <scriptarray.h>
#include <obfuscate.h>
#include <Poco/Exception.h>
#include <Poco/UnicodeConverter.h>
#include <SDL3/SDL.h>
#include <sstream>
#include "library.h"
#include "nvgt.h" // g_ScriptEngine, NVGT_SUBSYSTEM_DLLCALL
#include "pocostuff.h"
#include "serialize.h" // g_StringTypeid
#undef GetObject

// Maps AngelScript-style type name strings directly to the corresponding libffi
// type descriptors. Any type whose name ends with * is resolved to ffi_type_pointer
// by resolve_ffi_type() before this map is consulted.
static const std::unordered_map<std::string, ffi_type*> g_ffi_types = {
	{"void",   &ffi_type_void},
	{"bool",   &ffi_type_uint8},
	{"int8",   &ffi_type_sint8},  {"uint8",  &ffi_type_uint8},
	{"int16",  &ffi_type_sint16}, {"uint16", &ffi_type_uint16},
	{"int",    &ffi_type_sint32}, {"int32",  &ffi_type_sint32},
	{"uint",   &ffi_type_uint32}, {"uint32", &ffi_type_uint32},
	{"int64",  &ffi_type_sint64}, {"uint64", &ffi_type_uint64},
	{"float",  &ffi_type_float},  {"double", &ffi_type_double},
	{"char",   &ffi_type_sint8},  {"uchar",  &ffi_type_uint8},
	{"short",  &ffi_type_sint16}, {"ushort", &ffi_type_uint16},
	{"long",   &ffi_type_sint32}, {"ulong",  &ffi_type_uint32},
};

static std::string str_trim(const std::string& s) {
	size_t a = s.find_first_not_of(" \t\r\n");
	if (a == std::string::npos) return "";
	size_t b = s.find_last_not_of(" \t\r\n");
	return s.substr(a, b - a + 1);
}

static ffi_type* resolve_ffi_type(const std::string& type_str) {
	std::string t = str_trim(type_str);
	if (!t.empty() && t.back() == '*') return &ffi_type_pointer;
	auto it = g_ffi_types.find(t);
	return it != g_ffi_types.end() ? it->second : &ffi_type_pointer;
}

// --- library_function ---

library_function::library_function(const std::string& sig, SDL_SharedObject* so) : rtype(&ffi_type_void), func_ptr(nullptr), ref_count(1) {
	size_t paren_open = sig.find('(');
	size_t paren_close = sig.rfind(')');
	if (paren_open == std::string::npos || paren_close == std::string::npos)
		throw Poco::InvalidArgumentException("invalid signature: missing parentheses");
	std::string before = str_trim(sig.substr(0, paren_open));
	std::string args_part = str_trim(sig.substr(paren_open + 1, paren_close - paren_open - 1));
	size_t last_space = before.rfind(' ');
	if (last_space == std::string::npos)
		throw Poco::InvalidArgumentException("invalid signature: cannot separate return type from function name");
	rtype_string = str_trim(before.substr(0, last_space));
	rtype = resolve_ffi_type(rtype_string);
	std::string func_name = str_trim(before.substr(last_space + 1));
	if (!args_part.empty() && args_part != "void") {
		std::istringstream ss(args_part);
		std::string token;
		while (std::getline(ss, token, ',')) {
			std::string arg = str_trim(token);
			if (!arg.empty()) {
				arg_type_strings.push_back(arg);
				arg_types.push_back(resolve_ffi_type(arg));
			}
		}
	}
	func_ptr = (void*)SDL_LoadFunction(so, func_name.c_str());
	if (!func_ptr)
		throw Poco::NotFoundException("function not found in library: " + func_name);
	ffi_status st = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, (unsigned int)arg_types.size(), rtype, arg_types.empty() ? nullptr : arg_types.data());
	if (st != FFI_OK)
		throw Poco::RuntimeException("ffi_prep_cif failed with status " + std::to_string((int)st));
}

void library_function::add_ref() { asAtomicInc(ref_count); }
void library_function::release() { if (asAtomicDec(ref_count) < 1) delete this; }
void library_function::invalidate() { func_ptr = nullptr; error_text = "library was unloaded"; }

// Reads generic/variadic arguments from gen starting at arg_offset and calls the
// function via libffi.  AngelScript strings destined for char* args are passed as
// const char* pointers (kept alive in cstrs); strings destined for wchar* args are
// UTF-8→UTF-16 converted (kept alive in wstrs/wptrs).  Everything else is passed
// straight through via GetArgAddress.  Returns a typed poco_shared<Var>.
poco_shared<Poco::Dynamic::Var>* library_function::invoke(asIScriptGeneric* gen, int arg_offset) {
	if (!func_ptr) throw Poco::RuntimeException(error_text);
	if (!g_StringTypeid) g_StringTypeid = g_ScriptEngine->GetStringFactory();
	int nffi = (int)arg_types.size();
	int ngen = gen->GetArgCount() - arg_offset;
	if (ngen < nffi) throw Poco::InvalidArgumentException("expected " + std::to_string(nffi) + " arguments but got " + std::to_string(ngen));
	std::vector<void*> arg_ptrs;
	std::vector<const char*> cstrs; // keeps char* values addressable through ffi_call
	std::vector<std::wstring> wstrs; // keeps wchar_t buffers alive through ffi_call
	std::vector<const wchar_t*> wptrs; // addressable wchar_t* values into wstrs
	arg_ptrs.reserve(nffi);
	cstrs.reserve(nffi);
	wstrs.reserve(nffi);
	wptrs.reserve(nffi);
	for (int i = 0; i < nffi; i++) {
		int n = arg_offset + i;
		int tid = gen->GetArgTypeId(n);
		if (tid == g_StringTypeid && arg_types[i] == &ffi_type_pointer) {
			std::string* str = (std::string*)gen->GetArgAddress(n);
			#ifdef _WIN32
			if (arg_type_strings[i] == "wchar*") {
				std::wstring ws;
				Poco::UnicodeConverter::convert(*str, ws);
				wstrs.push_back(std::move(ws));
				wptrs.push_back(wstrs.back().c_str());
				arg_ptrs.push_back(&wptrs.back());
			} else
			#endif
			{
				cstrs.push_back(str->c_str());
				arg_ptrs.push_back(&cstrs.back());
			}
		} else {
			// GetArgAddress returns a pointer to the argument value — exactly
			// what ffi_call's avalue[i] expects for all other types.
			arg_ptrs.push_back(gen->GetArgAddress(n));
		}
	}
	union { ffi_arg i; float f; double d; } retval = {};
	ffi_call(&cif, FFI_FN(func_ptr), &retval, nffi > 0 ? arg_ptrs.data() : nullptr);
	auto make_var = [](auto v) {
		return new poco_shared<Poco::Dynamic::Var>(new Poco::Dynamic::Var(v));
	};
	// Pointer returns: char* and wchar* become std::string; other pointers return as uint64.
	if (rtype == &ffi_type_pointer) {
		if (rtype_string == "char*") {
			const char* s = reinterpret_cast<const char*>((uintptr_t)retval.i);
			return make_var(s ? std::string(s) : std::string());
		}
		#ifdef _WIN32
		else if (rtype_string == "wchar*") {
			const wchar_t* ws = reinterpret_cast<const wchar_t*>((uintptr_t)retval.i);
			std::string utf8;
			if (ws) Poco::UnicodeConverter::convert(std::wstring(ws), utf8);
			return make_var(utf8);
		}
		#endif
		return make_var((uint64_t)retval.i);
	}
	switch (rtype->type) {
	case FFI_TYPE_VOID:   return new poco_shared<Poco::Dynamic::Var>(new Poco::Dynamic::Var());
	case FFI_TYPE_UINT8:  return make_var((uint8_t)retval.i);
	case FFI_TYPE_SINT8:  return make_var((int8_t)retval.i);
	case FFI_TYPE_UINT16: return make_var((uint16_t)retval.i);
	case FFI_TYPE_SINT16: return make_var((int16_t)retval.i);
	case FFI_TYPE_UINT32: return make_var((uint32_t)retval.i);
	case FFI_TYPE_SINT32: return make_var((int32_t)retval.i);
	case FFI_TYPE_INT:    return make_var((int32_t)retval.i);
	case FFI_TYPE_UINT64: return make_var((uint64_t)retval.i);
	case FFI_TYPE_SINT64: return make_var((int64_t)retval.i);
	case FFI_TYPE_FLOAT:  return make_var(retval.f);
	case FFI_TYPE_DOUBLE: return make_var(retval.d);
	default:              return make_var((uint64_t)retval.i);
	}
}

// --- library ---

void library::add_ref() { asAtomicInc(ref_count); }
void library::release() { if (asAtomicDec(ref_count) < 1) { unload(); delete this; } }

bool library::load(const std::string& filename) {
	if (shared_object) return false;
	shared_object = SDL_LoadObject(filename.c_str());
	return shared_object != nullptr;
}

bool library::unload() {
	if (!shared_object) return false;
	for (auto& [sig, fn] : functions) { fn->invalidate(); fn->release(); }
	functions.clear();
	SDL_UnloadObject(shared_object);
	shared_object = nullptr;
	return true;
}

// Returns a library_function for the given signature, creating and caching it on
// first call. Throws on failure. The returned object is addref'd for the caller.
library_function* library::get(const std::string& sig) {
	if (!shared_object) throw Poco::RuntimeException("library not loaded");
	auto it = functions.find(sig);
	if (it != functions.end()) {
		it->second->add_ref();
		return it->second;
	}
	library_function* fn = new library_function(sig, shared_object); // throws on error
	fn->add_ref(); // cache holds one ref; initial ref from new goes to caller
	functions[sig] = fn;
	return fn;
}

void library::call(asIScriptGeneric* gen) {
	std::string* sig = (std::string*)gen->GetArgObject(0);
	library_function* fn = get(*sig); // throws if not loaded or signature is bad
	struct auto_release { library_function* p; ~auto_release() { p->release(); } } guard{fn};
	gen->SetReturnObject(fn->invoke(gen, 1));
}

// --- AngelScript glue ---

static library* new_script_library() { return new library(); }

static void library_function_opCall(asIScriptGeneric* gen) {
	library_function* self = (library_function*)gen->GetObject();
	gen->SetReturnObject(self->invoke(gen, 0));
}

static void library_call_wrapper(asIScriptGeneric* gen) {
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
	engine->RegisterObjectType(_O("library_function"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("library_function"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(library_function, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("library_function"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(library_function, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library_function"), _O("var@ opCall(?&in...)"), asFUNCTION(library_function_opCall), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("library_function"), _O("bool get_valid() const property"), asMETHOD(library_function, is_valid), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library_function"), _O("string get_error() const property"), asMETHOD(library_function, get_error), asCALL_THISCALL);
	engine->RegisterObjectType(_O("library"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("library"), asBEHAVE_FACTORY, _O("library @l()"), asFUNCTION(new_script_library), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("library"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(library, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("library"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(library, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("bool load(const string&in filename)"), asMETHOD(library, load), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("bool unload()"), asMETHOD(library, unload), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("bool get_active() const property"), asMETHOD(library, is_active), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("library_function@ get(const string&in sig)"), asMETHOD(library, get), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("library"), _O("var@ call(const string&in sig, ?&in...)"), asFUNCTION(library_call_wrapper), asCALL_GENERIC);
	engine->RegisterGlobalFunction(_O("string string_create_from_pointer(uint64 ptr, uint64 length)"), asFUNCTION(string_create_from_pointer), asCALL_CDECL);
}
