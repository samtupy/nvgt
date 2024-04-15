/* nvgt.cpp - program entry point
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

#ifdef _WIN32
	#include <windows.h>
	#include <direct.h>
	#include <locale.h>
#else
	#include <time.h>
	#include <unistd.h>
#endif
#define NVGT_LOAD_STATIC_PLUGINS
#include <Poco/Environment.h>
#include <Poco/Path.h>
#include <SDL2/SDL.h>
#include <angelscript.h> // the library
#include "angelscript.h" // nvgt's angelscript implementation
#include "input.h"
#include "misc_functions.h"
#include "nvgt.h"
#ifndef NVGT_USER_CONFIG
	#include "nvgt_config.h"
#else
	#include "../user/nvgt_config.h"
#endif
#include "sound.h"
#include "srspeech.h"
#include "timestuff.h"
#include "scriptarray.h"
#include "filesystem.h"


using namespace std;

CScriptArray* g_commandLineArgs = 0;
int g_argc = 0;
char** g_argv = 0;
bool g_debug = false;
asIScriptEngine* g_ScriptEngine = NULL;
std::string g_command_line;
int g_LastError;
int g_retcode = 0;
char g_exe_path[MAX_PATH];
bool g_initialising_globals = true;
bool g_shutting_down = false;
std::string g_stub = "";
std::string g_platform = "auto";
bool g_make_console = false;

const char* GetExecutableFilename() {
	if (g_exe_path[0] != 0)
		return g_exe_path;
	memset(g_exe_path, 0, MAX_PATH);
	std::string p = Poco::Path::self();
	strcpy(g_exe_path, p.c_str());
	return g_exe_path;
}

int main(int argc, char** argv) {
	//Todo: needs serious rewrite.
	g_argc = argc;
	bool skip_arg = true;
	#ifdef NVGT_STUB
	skip_arg = false;
	#endif
	#ifdef _WIN32
	setlocale(LC_ALL, ".UTF8");
	srand(GetTickCount());
	const char* cmdline = GetCommandLineA();
	const char* cmdline2 = NULL;
	bool instring = false;
	timestuff_startup();
	for (int i = 0; cmdline[i]; i++) {
		if (cmdline[i] == '\"') instring = !instring;
		if (!instring && cmdline[i] == ' ' && cmdline[i + 1]) {
			if (cmdline[i + 1] == ' ') continue;
			if (skip_arg) {
				skip_arg = false;
				continue;
			}
			cmdline2 = cmdline + i + 1;
			break;
		}
	}
	if (cmdline2) g_command_line = cmdline2;
	else g_command_line = "";
	#else
	for (int i = (skip_arg ? 2 : 1); i < argc; i++) {
		bool space = strchr(argv[i], ' ') != NULL;
		if (space) g_command_line += "\"";
		g_command_line += argv[i];
		if (space) g_command_line += "\"";
		if (i < argc) g_command_line += " ";
	}
	#endif
	char* scriptfile = NULL;
	int mode = 0;
	#ifndef NVGT_STUB
	if (argc < 2)
		return 0;
	if (strcmp(argv[1], "-c") == 0) mode = 1;
	else if (strcmp(argv[1], "-C") == 0) mode = 2;
	if (mode == 0)
		scriptfile = argv[1];
	else
		scriptfile = argv[2];
	#endif
	asIScriptEngine* engine = asCreateScriptEngine();
	if (!engine) {
		ShowAngelscriptMessages();
		return 1;
	}
	g_ScriptEngine = engine;
	if (ConfigureEngine(engine) < 0) {
		ShowAngelscriptMessages();
		return 1;
	}
	#ifndef NVGT_STUB
	asINT64 timer = ticks();
	g_debug = mode != 1;
	if (!g_debug)
		engine->SetEngineProperty(asEP_BUILD_WITHOUT_LINE_CUES, true);
	if (CompileScript(engine, scriptfile) < 0) {
		ShowAngelscriptMessages();
		return 1;
	}
	#else
	const char* fn = GetExecutableFilename();
	int loc = 0;
	int size = 0;
	FILE* f = fopen(fn, "rb");
	#ifdef _WIN32
	fseek(f, 56, SEEK_SET);
	fread(&loc, 4, 1, f);
	if (loc == 0)
		return 1;
	fseek(f, loc, SEEK_SET);
	if (!load_serialized_nvgt_plugins(f))
		return 1;
	fread(&size, 4, 1, f);
	size ^= NVGT_BYTECODE_NUMBER_XOR;
	#else
	fseek(f, -4, SEEK_END);
	fread(&size, 4, 1, f);
	size ^= NVGT_BYTECODE_NUMBER_XOR;
	fseek(f, -(size + 4), SEEK_END);
	#endif
	unsigned char* code = (unsigned char*)malloc(size);
	fread(code, sizeof(char), size, f);
	fclose(f);
	if (LoadCompiledScript(engine, code, size) < 0) {
		ShowAngelscriptMessages();
		return 1;
	}
	#endif
	if (mode == 0) {
		if (ExecuteScript(engine, scriptfile) < 0) {
			ShowAngelscriptMessages();
			ScreenReaderUnload();
			return 1;
		}
		g_shutting_down = true;
		ScreenReaderUnload();
		InputDestroy();
	}
	#ifndef NVGT_STUB
	else {
		#ifdef _WIN32
		if (g_platform == "auto") g_platform = "windows";
		#elif defined(__linux__)
		if (g_platform == "auto") g_platform = "linux";
		#elif defined(__APPLE__)
		if (g_platform == "auto") g_platform = "mac";
		#else
		return 1;
		#endif
		char msg[1024];
		char final_scriptname[MAX_PATH];
		memset(final_scriptname, 0, MAX_PATH);
		if (g_compiled_basename != "") {
			g_compiled_basename += ".nvgt";
			strcpy(final_scriptname, g_compiled_basename.c_str());
		} else
			strcpy(final_scriptname, scriptfile);
		char* dot = strrchr(final_scriptname, '.');
		if (g_platform == "windows")
			strcpy(dot, ".exe");
		else if (dot)
			*dot = '\0';
		char stub_loc[MAX_PATH];
		memset(stub_loc, 0, MAX_PATH);
		std::string stub = "nvgt_";
		stub += g_platform;
		if (g_stub != "") {
			stub += "_";
			stub += g_stub;
		}
		stub += ".bin";
		const char* fn = GetExecutableFilename();
		const char* dir = strrchr(fn, '\\');
		if (dir == NULL) dir = strrchr(fn, '/');
		if (dir == NULL) {
			snprintf(msg, 512, "Failed to find %s!", stub.c_str());
			message(msg, "compilation failure");
			engine->ShutDownAndRelease();
			return 1;
		}
		strncpy(stub_loc, fn, dir - fn);
		#ifdef _WIN32
		strcat(stub_loc, "\\");
		#else
		strcat(stub_loc, "/");
		#endif
		strcat(stub_loc, stub.c_str());
		if (!FileCopy(stub_loc, final_scriptname, true)) {
			snprintf(msg, 512, "Failed to prepare compilation output (either missing %s or failed to copy it)", stub.c_str());
			message(msg, "compilation failure");
			engine->ShutDownAndRelease();
			return 1;
		}
		int size = FileGetSize(final_scriptname);
		FILE* f = fopen(final_scriptname, "rb+");
		if (g_platform == "windows") {
			fseek(f, 0, SEEK_SET);
			char tmp[3];
			strcpy(tmp, "MZ");
			fwrite(&tmp, 1, 2, f);
			fseek(f, 56, SEEK_SET);
			fwrite(&size, 1, 4, f);
			if (g_make_console) {
				int subsystem_offset;
				fseek(f, 60, SEEK_SET); // position of new PE header address.
				fread(&subsystem_offset, 1, 4, f);
				subsystem_offset += 92; // offset in new PE header containing subsystem word. 2 for GUI, 3 for console.
				fseek(f, subsystem_offset, SEEK_SET);
				unsigned short new_subsystem = 3;
				fwrite(&new_subsystem, 1, 2, f);
			}
			fseek(f, size, SEEK_SET);
		} else if (g_platform == "linux" || g_platform == "mac")
			fseek(f, 0, SEEK_END);
		serialize_nvgt_plugins(f);
		const unsigned char* code = NULL;
		int bcsize = SaveCompiledScript(engine, &code);
		if (bcsize < 1) {
			message("Failed to retrieve script compilation output", "compilation failure");
			engine->ShutDownAndRelease();
			return 1;
		}
		int wsize = bcsize ^ NVGT_BYTECODE_NUMBER_XOR;
		if (g_platform == "windows")
			fwrite(&wsize, 1, 4, f);
		fwrite(code, 1, bcsize, f);
		if (g_platform == "linux" || g_platform == "mac")
			fwrite(&wsize, 1, 4, f);
		fclose(f);
		snprintf(msg, 1024, "%s build succeeded in %lldms, saved to %s", (g_debug ? "Debug" : "Release"), (long long int)(ticks() - timer), final_scriptname);
		message(msg, "Success!");
	}
	#endif
	engine->ShutDownAndRelease();
	return 0;
}

void message(const std::string& text, const std::string& header) {
	#ifdef _WIN32
	MessageBoxA(0, text.c_str(), header.c_str(), 0);
	#else
	std::string tmp = header;
	tmp += ": ";
	tmp += text;
	printf("%s", tmp.c_str());
	#endif
}

// To make building stubs easier, we put this here so that theoretically only angelscript.cpp and nvgt.cpp need to be rebuilt when making stubs.
bool script_compiled() {
	#ifdef NVGT_STUB
	return true;
	#else
	return false;
	#endif
}


#ifndef _WIN32
int Sleep(long msec) {
	struct timespec ts;
	int res;
	if (msec < 0) {
		errno = EINVAL;
		return -1;
	}
	ts.tv_sec = msec / 1000;
	ts.tv_nsec = (msec % 1000) * 1000000;
	do {
		res = nanosleep(&ts, &ts);
	} while (res && errno == EINTR);
	return res;
}
#endif
