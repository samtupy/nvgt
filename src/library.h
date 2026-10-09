/* library.h - header for the dll call/library object
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

#pragma once

#include <string>
#include <unordered_map>
#include <vector>
#include <ffi.h>
#include <SDL3/SDL_loadso.h>

// Forward declarations so library.h doesn't drag in Poco or scriptarray headers.
namespace Poco { namespace Dynamic { class Var; } }
template <class T> class poco_shared;

class asIScriptEngine;
class asIScriptGeneric;

class library_function {
	ffi_cif cif;
	std::vector<ffi_type*> arg_types;
	std::vector<std::string> arg_type_strings; // raw per-arg type strings for char*/wchar* detection
	ffi_type* rtype;
	std::string rtype_string; // raw return type string for char*/wchar* detection
	void* func_ptr;
	std::string error_text; // set only by invalidate(), checked in invoke()
	int ref_count;
public:
	library_function(const std::string& sig, SDL_SharedObject* so);
	void add_ref();
	void release();
	void invalidate();
	bool is_valid() const { return func_ptr != nullptr; }
	std::string get_error() const { return error_text; }
	poco_shared<Poco::Dynamic::Var>* invoke(asIScriptGeneric* gen, int arg_offset);
};

class library {
	SDL_SharedObject* shared_object;
	std::unordered_map<std::string, library_function*> functions;
	int ref_count;
public:
	library() : shared_object(nullptr), ref_count(1) {}
	void add_ref();
	void release();
	bool load(const std::string& filename);
	bool unload();
	bool is_active() const { return shared_object != nullptr; }
	library_function* get(const std::string& sig);
	void call(asIScriptGeneric* gen);
};

void RegisterScriptLibrary(asIScriptEngine* engine);
