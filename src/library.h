/* library.h - header for the dll call/library object
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

#include <string>
#include <unordered_map>
#include <SDL3/SDL_loadso.h>

class asIScriptEngine;
class asIScriptFunction;
class CScriptDictionary;

class library {
	asIScriptEngine* engine;
	std::string engine_errors;
	SDL_SharedObject* shared_object;
	std::unordered_map<std::string, asIScriptFunction*> functions;
	int ref_count;
	int ptr_type_id;
public:
	library() : engine(NULL), shared_object(NULL), ptr_type_id(0), ref_count(1) {};
	void add_ref();
	void release();
	bool load(const std::string& filename);
	bool unload();
	bool is_active() {
		return engine && shared_object;
	}
	void call(asIScriptGeneric* gen);
};

void RegisterScriptLibrary(asIScriptEngine* engine);
