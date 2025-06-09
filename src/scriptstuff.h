/* subscripting.h - angelscript subscripting implementation header and various scripting related routines
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
#include <angelscript.h>
#include "nvgt.h"

bool script_compiled();
void profiler_callback(asIScriptContext* ctx, void* obj);
extern int g_GCMode;
void prepare_profiler();
void garbage_collect_action();
extern asIScriptFunction* profiler_last_func;
extern int profiler_current_line;
extern const char* profiler_current_section;
std::string get_call_stack();
void RegisterScriptstuff(asIScriptEngine* engine);
