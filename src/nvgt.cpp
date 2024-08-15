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
#include <Poco/Util/IntValidator.h>
#include <Poco/Util/IniFileConfiguration.h>
#include <Poco/Util/RegExpValidator.h>
#include <Poco/Environment.h>
#include <Poco/File.h>
#include <Poco/Path.h>
#include <Poco/UnicodeConverter.h>
#include <SDL3/SDL.h>
#include "filesystem.h"
#include "scriptarray.h"
#define NVGT_LOAD_STATIC_PLUGINS
#include "angelscript.h" // nvgt's angelscript implementation
#ifdef __APPLE__
#include "apple.h" // apple_requested_file
#endif
#include "input.h"
#include "nvgt.h"
#ifndef NVGT_USER_CONFIG
	#include "nvgt_config.h"
#else
	#include "../user/nvgt_config.h"
#endif
#include "random.h" // random_seed()
#include "serialize.h" // current location of g_StringTypeid (subject to change)
#include "sound.h"
#include "srspeech.h"
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
		#ifndef NVGT_STUB
		loadConfiguration(); // This will load config files with the basename of the currently running executable.
		// We also want to look for config.json/.ini/.properties so that the user can create global configuration properties despite whether nvgt.exe or nvgtw.exe is being run.
		Path confpath = Path(config().getString("application.dir")).setFileName("config.ini");
		if (File(confpath).exists()) loadConfiguration(confpath.toString(), 1);
		confpath.setExtension("properties");
		if (File(confpath).exists()) loadConfiguration(confpath.toString(), 1);
		confpath.setExtension("json");
		if (File(confpath).exists()) loadConfiguration(confpath.toString(), 1);
		#endif
		Application::initialize(self);
		#ifdef _WIN32
		timeBeginPeriod(1);
		setlocale(LC_ALL, ".UTF8");
		wstring dir_u;
		UnicodeConverter::convert(Path(config().getString("application.dir")).append("lib").toString(), dir_u);
		SetDllDirectoryW(dir_u.c_str());
		#elif defined(__APPLE__)
		if (Environment::has("MACOS_BUNDLED_APP")) { // Use GUI instead of stdout and chdir to Resources directory.
			config().setString("application.gui", "");
			#ifdef NVGT_STUB
				chdir(Path(config().getString("application.dir")).parent().pushDirectory("Resources").toString().c_str());
			#endif
		}
		#endif
		srand(random_seed()); // Random bits of NVGT if not it's components might use the c rand function.
		#if defined(NVGT_WIN_APP) || defined(NVGT_STUB)
		config().setString("application.gui", "");
		#endif
		g_ScriptEngine = asCreateScriptEngine();
		if (!g_ScriptEngine || ConfigureEngine(g_ScriptEngine) < 0) throw ApplicationException("unable to initialize script engine");
	}
	void setupCommandLineProperty(const vector<string>& argv, int offset = 0) {
		// Prepare the COMMAND_LINE property used by scripts by combining all arguments into one string, for bgt backwards compatibility. NVGT also has a new ARGS array which we will also set up here.
		if (!g_StringTypeid)
			g_StringTypeid = g_ScriptEngine->GetStringFactory();
		g_command_line_args = CScriptArray::Create(g_ScriptEngine->GetTypeInfoByDecl("string[]"));
		for (unsigned int i = offset; i < argv.size(); i++) {
			g_CommandLine += argv[i];
			g_command_line_args->InsertLast((void*)&argv[i]);
			if (i < argv.size() - 1) g_CommandLine += " ";
		}
	}
	#ifndef NVGT_STUB
	void defineOptions(OptionSet& options) override {
		Application::defineOptions(options);
		options.addOption(Option("compile", "c", "compile script in release mode").group("compiletype"));
		options.addOption(Option("compile-debug", "C", "compile script in debug mode").group("compiletype"));
		options.addOption(Option("platform", "p", "select target platform to compile for (auto|windows|linux|mac)", false, "platform", true).validator(new RegExpValidator("^(auto|windows|linux|mac)$")));
		options.addOption(Option("quiet", "q", "do not output anything upon successful compilation").binding("application.quiet").group("quiet"));
		options.addOption(Option("QUIET", "Q", "do not output anything (work in progress), error status must be determined by process exit code (intended for automation)").binding("application.QUIET").group("quiet"));
		options.addOption(Option("debug", "d", "run with the Angelscript debugger").binding("application.as_debug"));
		options.addOption(Option("warnings", "w", "select how script warnings should be handled (0 ignore (default), 1 print, 2 treat as error)", false, "level", true).binding("scripting.compiler_warnings").validator(new IntValidator(0, 2)));
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
		else if (name == "platform") g_platform = value;
	}
	void displayHelp() {
		HelpFormatter hf(options());
		hf.setUnixStyle(true);
		hf.setIndent(4); // Visually appealing vs. accessibility and usability. The latter wins.
		hf.setCommand(commandName());
		hf.setUsage("[options] script [-- arg1 arg2 ...]");
		hf.setHeader("NonVisual Gaming Toolkit (NVGT) - available command line arguments");
		hf.setFooter("A script file is required.");
		if (!config().hasOption("application.gui")) hf.format(cout);
		else {
			stringstream ss;
			hf.format(ss);
			message(ss.str(), "help");
		}
	}
	virtual int main(const std::vector<std::string>& args) override {
		// Determine the script file that is to be executed.
		string scriptfile = "";
		#ifdef __APPLE__
			scriptfile = apple_requested_file(); // Files opened from finder on mac do not use command line arguments.
		#endif
		if (scriptfile.empty() && args.size() > 0) scriptfile = args[0];
		if (mode == NVGT_HELP) {
			displayHelp();
			return Application::EXIT_OK;
		} else if (mode == NVGT_VERSIONINFO) {
			string ver = format("NVGT (NonVisual Gaming Toolkit) version %s, built on %s for %s %s", NVGT_VERSION, NVGT_VERSION_BUILD_TIME, Environment::osName(), Environment::osArchitecture());
			if (config().hasOption("application.gui")) message(ver, "version information");
			else cout << ver << endl;
			return Application::EXIT_OK;
		} else if (scriptfile.empty()) {
			message("error, no input files.\nType " + commandName() + " --help for usage instructions\n", commandName());
			return Application::EXIT_USAGE;
		}
		try {
			// Parse the provided script path to insure it is valid and check if it is a file.
			if (!File(Path(scriptfile)).isFile()) throw Exception("Expected a file", scriptfile);
			// The scripter is able to create configuration files that can change some behaviours of the engine, such files are named after the script that is to be run.
			Path conf_file(scriptfile);
			conf_file.setExtension("properties");
			if (File(conf_file).exists()) loadConfiguration(conf_file.toString(), -2);
			conf_file.setExtension("ini");
			if (File(conf_file).exists()) loadConfiguration(conf_file.toString(), -2);
			conf_file.setExtension("json");
			if (File(conf_file).exists()) loadConfiguration(conf_file.toString(), -2);
			// The user can also place a .nvgtrc file in the current directory of their script or any parent of it, expected to be in ini format.
			conf_file.setFileName(".nvgtrc");
			while (conf_file.depth() > 0 && !File(conf_file).exists()) conf_file.popDirectory();
			if (File(conf_file).exists()) config().addWriteable(new IniFileConfiguration(conf_file.toString()), -1);
		} catch (Poco::Exception& e) {
			message(e.displayText(), "error");
			return Application::EXIT_CONFIG;
		}
		setupCommandLineProperty(args, 1);
		g_command_line_args->InsertAt(0, (void*)&scriptfile);
		ConfigureEngineOptions(g_ScriptEngine);
		if (CompileScript(g_ScriptEngine, scriptfile.c_str()) < 0) {
			ShowAngelscriptMessages();
			return Application::EXIT_DATAERR;
		}
		if (config().hasOption("application.as_debug")) {
			if (config().hasOption("application.gui")) {
				message("please use the command line version of nvgt if you wish to invoque the debugger", "error");
				return Application::EXIT_CONFIG;
			}
			#if !defined(NVGT_STUB) && !defined(NVGT_WIN_APP)
			else InitializeDebugger(g_ScriptEngine);
			#endif
		}
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
		std::string path_tmp;
		g_command_line_args->InsertAt(0, (void*)&path_tmp);
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
		#ifdef _WIN32
		timeEndPeriod(1);
		#endif
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
#include <SDL3/SDL_main.h>
int main(int argc, char** argv) {
	AutoPtr<Application> app = new nvgt_application();
	try {
		app->init(argc, argv);
	} catch (Poco::Exception& e) {
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

