/* nvgt_angelscript.h - Angelscript integration header
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
#include <vector>
#include <angelscript.h>
#include <scriptarray.h>
#include <Poco/Format.h>

extern std::string g_compiled_basename;
extern CScriptArray* g_command_line_args;
extern std::string g_CommandLine;
extern std::vector<std::string> g_IncludeDirs;
extern std::vector<std::string> g_IncludeScripts;
std::string get_system_namespace(const std::string& system);

void ShowAngelscriptMessages();
int PreconfigureEngine(asIScriptEngine* engine);
int ConfigureEngine(asIScriptEngine* engine);
void ConfigureEngineOptions(asIScriptEngine* engine);
int ExecuteScript(asIScriptEngine* engine, const std::string& scriptFile);
#ifndef NVGT_STUB
	int               CompileScript(asIScriptEngine* engine, const std::string& scriptFile);
	int SaveCompiledScript(asIScriptEngine* engine, unsigned char** output);
	int CompileExecutable(asIScriptEngine* engine, const std::string& scriptFile);
	void              InitializeDebugger(asIScriptEngine* engine);
#else
	int LoadCompiledScript(asIScriptEngine* engine, unsigned char* code, asUINT size);
	int LoadCompiledExecutable(asIScriptEngine* engine);
#endif
asITypeInfo* get_array_type(const std::string& decl);
template <class T> inline CScriptArray* vector_to_scriptarray(const std::vector<T>& input, const std::string& array_type) {
	asITypeInfo* t = get_array_type(Poco::format("array<%s>", array_type));
	if (!t) return nullptr;
	CScriptArray* array = CScriptArray::Create(t, input.size());
	for (int i = 0; i < input.size(); i++) ((T*)array->At(i))->operator=(input[i]);
	return array;
}

void RegisterUnsorted(asIScriptEngine* engine);
