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

#include <iostream>
#include <sstream>
#define SDL_MAIN_HANDLED // We do actually use SDL_main, but see below near the bottom of the file.
#ifdef _WIN32
	#include <windows.h>
	#include <locale.h>
#else
	#include <time.h>
	#include <unistd.h>
#endif
#include <angelscript.h> // the library
#include <Poco/Util/Application.h>
#include <Poco/Util/HelpFormatter.h>
#include <Poco/Util/OptionSet.h>
#include <Poco/Environment.h>
#include <Poco/Path.h>
#include <Poco/UnicodeConverter.h>
#include <SDL2/SDL.h>
#include "filesystem.h"
#include "scriptarray.h"
#define NVGT_LOAD_STATIC_PLUGINS
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
#include "UI.h" // message
#include "version.h"


using namespace std;
using namespace Poco;
using namespace Poco::Util;

class nvgt_application : public Poco::Util::Application {
		enum run_mode {NVGT_RUN, NVGT_COMPILE, NVGT_HELP, NVGT_VERSIONINFO};
		run_mode mode;
	public:
		nvgt_application() : mode(NVGT_RUN) {
			setUnixOptions(true);
			#ifdef NVGT_STUB
				stopOptionsProcessing(); // The command line is completely controled by the scripter in the case of a compiled executable.
			#endif
		}
	protected:
		void initialize(Application& self) override {
			loadConfiguration();
			Application::initialize(self);
			#ifdef _WIN32
				setlocale(LC_ALL, ".UTF8");
				timestuff_startup();
				wstring dir_u;
				UnicodeConverter::convert(Path(config().getString("application.dir")).append("lib").toString(), dir_u);
				SetDllDirectoryW(dir_u.c_str());
			#endif
			srand(ticks()); // Random bits of NVGT if not it's components might use the c rand function.
			#if defined(NVGT_WIN_APP) || defined(NVGT_STUB)
				config().setString("application.gui", "");
			#endif
		}
		void setupCommandLineProperty(const vector<string>& argv, int offset = 0) {
			// Prepare the COMMAND_LINE property used by scripts by combining all arguments into one string, for bgt backwards compatibility.
			for (unsigned int i = offset; i < argv.size(); i++) {
				g_CommandLine += argv[i];
				if (i < argv.size() -1) g_CommandLine += " ";
			}
			g_ScriptEngine = asCreateScriptEngine();
			if (!g_ScriptEngine || ConfigureEngine(g_ScriptEngine) < 0) throw ApplicationException("unable to initialize script engine");
		}
		#ifndef NVGT_STUB
		void defineOptions(OptionSet& options) override {
			Application::defineOptions(options);
			options.addOption(Option("compile", "c", "compile script in release mode").group("compiletype"));
			options.addOption(Option("compile-debug", "C", "compile script in debug mode").group("compiletype"));
			options.addOption(Option("quiet", "q", "do not output anything upon successful compilation").binding("application.quiet").group("quiet"));
			options.addOption(Option("QUIET", "Q", "do not output anything (work in progress), error status must be determined by process exit code (intended for automation)").binding("application.QUIET").group("quiet"));
			options.addOption(Option("debug", "d", "run with the Angelscript debugger").binding("application.as_debug"));
			options.addOption(Option("include", "i", "include an aditional script similar to the #include directive", false, "script", true).repeatable(true));
			options.addOption(Option("include-directory", "I", "add an aditional directory to the search path for included scripts", false, "directory", true).repeatable(true));
			options.addOption(Option("version", "V", "print version information and exit"));
			options.addOption(Option("help", "h", "display available command line options"));
		}
		void handleOption(const std::string& name, const std::string& value) override {
			Application::handleOption(name, value);
			if (name == "help") {
				mode = NVGT_HELP;
				stopOptionsProcessing();
			} else if (name == "version") {
				mode = NVGT_VERSIONINFO;
				stopOptionsProcessing();
			} else if (name == "compile" || name == "compile-debug") {
				mode = NVGT_COMPILE;
				g_debug = name == "compile-debug";
			} else if (name == "include-directory") g_IncludeDirs.push_back(value);
			else if (name == "include") g_IncludeScripts.push_back(value);
		}
		void displayHelp() {
			HelpFormatter hf(options());
			hf.setUnixStyle(true);
			hf.setIndent(4); // Visually appealing vs. accessibility and usability. The latter wins.
			hf.setCommand(commandName());
			hf.setUsage("[options] script [-- arg1 arg2 ...]");
			hf.setHeader("NonVisual Gaming Toolkit (NVGT) - available command line arguments");
			hf.setFooter("A script file is required.");
			#ifndef NVGT_WIN_APP
				hf.format(cout);
			#else
				stringstream ss;
				hf.format(ss);
				message(ss.str(), "help");
			#endif
		}
		virtual int main(const std::vector<std::string>& args) override {
			if (mode == NVGT_HELP) {
				displayHelp();
				return Application::EXIT_OK;
			} else if (mode == NVGT_VERSIONINFO) {
				string ver = format("NVGT (NonVisual Gaming Toolkit) version %s, built on %s for %s %s", NVGT_VERSION, NVGT_VERSION_BUILD_TIME, Environment::osName(), Environment::osArchitecture());
				#ifdef NVGT_WIN_APP
					message(ver, "version information");
				#else
					cout << ver << endl;
				#endif
				return Application::EXIT_OK;
			} else if (args.size() < 1) {
				std::cout << commandName() << ": error, no input files." << std::endl << "type " << commandName() << " --help for usage instructions" << std::endl;
				return Application::EXIT_USAGE;
			}
			string scriptfile = args[0];
			setupCommandLineProperty(args, 1);
			if (CompileScript(g_ScriptEngine, scriptfile.c_str()) < 0) {
				ShowAngelscriptMessages();
				return Application::EXIT_DATAERR;
			}
			#if !defined(NVGT_STUB) && !defined(NVGT_WIN_APP)
				if (config().hasOption("application.as_debug")) InitializeDebugger(g_ScriptEngine);
			#elif defined(NVGT_WIN_APP)
				if (config().hasOption("application.as_debug")) {
					message("please use the command line version of nvgt if you wish to invoque the debugger", "error");
					return Application::EXIT_CONFIG;
				}
			#endif
			int retcode = Application::EXIT_OK;
			if (mode == NVGT_RUN && (retcode = ExecuteScript(g_ScriptEngine, scriptfile.c_str())) < 0 || mode == NVGT_COMPILE && CompileExecutable(g_ScriptEngine, scriptfile)) {
				ShowAngelscriptMessages();
				return Application::EXIT_SOFTWARE;
			}
			return retcode;
		}
		#else
		virtual int main(const std::vector<std::string>& args) override {
			setupCommandLineProperty(args);
			int retcode = Application::EXIT_OK;
			if (LoadCompiledExecutable(g_ScriptEngine) < 0 || (retcode = ExecuteScript(g_ScriptEngine, commandName().c_str())) < 0) {
				ShowAngelscriptMessages();
				return Application::EXIT_DATAERR;
			}
			return retcode;
		}
		#endif
		void uninitialize() override {
			g_shutting_down = true;
			Application::uninitialize();
			ScreenReaderUnload();
			InputDestroy();
			if (g_ScriptEngine) g_ScriptEngine->ShutDownAndRelease();
			g_ScriptEngine = nullptr;
		}
};

// Poco::Util::Application and SDL_main conflict, macro magic in SDL_main.h is replacing all occurances of "main" with "SDL_main", including the one in nvgt's derived Poco application causing the overwritten method to not call. Hack around that. You are about to scroll past 5 utterly simple lines of code that took hours of frustration and mind pain to determine the nesessety of.
#if !defined(_WIN32) || defined(NVGT_WIN_APP) || defined(NVGT_STUB)
#undef SDL_MAIN_HANDLED
#undef SDL_main_h_
#include <SDL2/SDL_main.h>
int main(int argc, char** argv) {
	AutoPtr<Application> app = new nvgt_application();
	try {
		app->init(argc, argv);
	} catch(Poco::Exception& e) {
		#ifndef NVGT_WIN_APP
		app->logger().fatal(e.displayText());
		#else
			message(e.displayText(), "initialization error");
		#endif
		return Application::EXIT_CONFIG;
	}
	return app->run();
}
#else
POCO_APP_MAIN(nvgt_application); // We don't use SDL_main for windows console nvgt, POCO_APP_MAIN handles UTF16 command line arguments for us via wmain.
#endif

