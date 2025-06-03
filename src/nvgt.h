/* nvgt.h - externs from nvgt.cpp needed by other parts of the application / a bit of other misc
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
#include "nvgt_plugin.h" // subsystems

class asIScriptEngine;
extern bool g_debug;
extern asIScriptEngine* g_ScriptEngine;
extern int g_LastError;
extern int g_retcode;
extern bool g_initialising_globals;
extern bool g_shutting_down;
extern std::string g_stub;
extern std::string g_scriptpath;
extern std::string g_platform;
extern bool g_make_console;

#ifndef _WIN32
	#ifndef BOOL
		typedef int BOOL;
		#define FALSE 0
		#define TRUE 1
	#endif
	typedef unsigned int DWORD;
#endif
