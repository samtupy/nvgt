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

#include <exception>
#include <iostream>
#include <sstream>
#define SDL_MAIN_HANDLED // We do actually use SDL_main, but see below near the bottom of the file.
#ifdef _WIN32
	#define NOMINMAX
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
#include "nvgt_angelscript.h" // nvgt's angelscript implementation
#include "bundling.h"
#include "input.h"
#include "misc_functions.h" // ChDir
#include "nvgt.h"
#ifndef NVGT_USER_CONFIG
	#include "nvgt_config.h"
#else
	#include "../user/nvgt_config.h"
#endif
#include "random.h"    // random_seed()
#include "serialize.h" // current location of g_StringTypeid (subject to change)
#include "sound.h"
#include "srspeech.h"
#include "UI.h" // message
#include "version.h"
#include "xplatform.h"
#include "anticheat.h"

using namespace std;
using namespace Poco;
using namespace Poco::Util;

class nvgt_application : public Poco::Util::Application {
	enum run_mode {
		NVGT_RUN,
		NVGT_COMPILE,
		NVGT_HELP,
		NVGT_VERSIONINFO,
		NVGT_EXIT
	};
	run_mode mode;

public:
	nvgt_application() : mode(NVGT_RUN) {
		setUnixOptions(true);
		#ifdef NVGT_STUB
		stopOptionsProcessing(); // The command line is completely controled by the scripter in the case of a compiled executable.
		#endif
	}

protected:
	void initialize(Application &self) override {
		#ifndef NVGT_STUB
		loadConfiguration(); // This will load config files with the basename of the currently running executable.
		// We also want to look for config.json/.ini/.properties so that the user can create global configuration properties despite whether nvgt.exe or nvgtw.exe is being run.
		Path confpath = Path(config().getString("application.dir")).setFileName("config.ini");
		if (File(confpath).exists())
			loadConfiguration(confpath.toString(), 1);
		confpath.setExtension("properties");
		if (File(confpath).exists())
			loadConfiguration(confpath.toString(), 1);
		confpath.setExtension("json");
		if (File(confpath).exists())
			loadConfiguration(confpath.toString(), 1);
		#endif
		Application::initialize(self);
		#ifdef _WIN32
		timeBeginPeriod(1);
		setlocale(LC_ALL, ".UTF8");
		wstring dir_u;
		UnicodeConverter::convert(Path(config().getString("application.dir")).append("lib").toString(), dir_u);
		SetDllDirectoryW(dir_u.c_str());
		CreateMutexW(nullptr, false, L"NVGTApplication"); // This mutex will automatically be freed by the OS on process termination so we don't need a handle to it, this exists only so the NVGT windows installer or anything else on windows can tell that NVGT is running without process enumeration.
		#elif defined(__APPLE__)
		std::string resources_dir = Path(config().getString("application.dir")).parent().pushDirectory("Resources").toString();
		if (Environment::has("MACOS_BUNDLED_APP")) {
			// Use GUI instead of stdout and chdir to Resources directory.
			config().setString("application.gui", "");
			#ifdef NVGT_STUB
			ChDir(resources_dir);
			#endif
		}
		#ifndef NVGT_STUB
		if (File(resources_dir).exists())
			g_IncludeDirs.push_back(Path(resources_dir).pushDirectory("include").toString());
		#endif
		#elif defined(__ANDROID__)
		config().setString("application.gui", "");
		#endif
		srand(random_seed()); // Random bits of NVGT if not it's components might use the c rand function.
		#if defined(NVGT_WIN_APP) || defined(NVGT_STUB)
		config().setString("application.gui", "");
		#endif
		g_ScriptEngine = asCreateScriptEngine();
		if (!g_ScriptEngine || PreconfigureEngine(g_ScriptEngine) < 0) throw ApplicationException("unable to initialize script engine");
	}
	void setupCommandLineProperty(const vector<string> &argv, int offset = 0) {
		// Prepare the COMMAND_LINE property used by scripts by combining all arguments into one string, for bgt backwards compatibility. NVGT also has a new ARGS array which we will also set up here.
		if (!g_StringTypeid)
			g_StringTypeid = g_ScriptEngine->GetStringFactory();
		g_command_line_args = CScriptArray::Create(g_ScriptEngine->GetTypeInfoByDecl("string[]"));
		for (unsigned int i = offset; i < argv.size(); i++) {
			g_CommandLine += argv[i];
			g_command_line_args->InsertLast((void *)&argv[i]);
			if (i < argv.size() - 1)
				g_CommandLine += " ";
		}
	}
	#ifndef NVGT_STUB
	void defineOptions(OptionSet &options) override {
		Application::defineOptions(options);
		options.addOption(Option("compile", "c", "compile script in release mode").group("compiletype"));
		options.addOption(Option("compile-debug", "C", "compile script in debug mode").group("compiletype"));
		options.addOption(Option("platform", "p", "select target platform to compile for (auto|windows|linux|mac|android)", false, "platform", true).validator(new RegExpValidator("^(auto|windows|linux|mac|android)$")));
		options.addOption(Option("quiet", "q", "do not output anything upon successful compilation").binding("application.quiet").group("quiet"));
		options.addOption(Option("QUIET", "Q", "do not output anything (work in progress), error status must be determined by process exit code (intended for automation)").binding("application.QUIET").group("quiet"));
		options.addOption(Option("debug", "d", "run with the Angelscript debugger").binding("application.as_debug"));
		options.addOption(Option("warnings", "w", "select how script warnings should be handled (0 ignore (default), 1 print, 2 treat as error)", false, "level", true).binding("scripting.compiler_warnings").validator(new IntValidator(0, 2)));
		options.addOption(Option("asset", "a", "bundle an asset when compiling similar to the #pragma asset directive", false, "path", true).repeatable(true));
		options.addOption(Option("asset-document", "A", "bundle a document asset when compiling similar to the #pragma document directive", false, "path", true).repeatable(true));
		options.addOption(Option("include", "i", "include an aditional script similar to the #include directive", false, "script", true).repeatable(true));
		options.addOption(Option("include-directory", "I", "add an aditional directory to the search path for included scripts", false, "directory", true).repeatable(true));
		options.addOption(Option("set", "s", "set a configuration property", false, "name=value", true).repeatable(true));
		options.addOption(Option("settings", "S", "set additional configuration properties from a file", false, "path", true).repeatable(true));
		options.addOption(Option("version", "V", "print version information and exit"));
		options.addOption(Option("help", "h", "display available command line options"));
	}
	void handleOption(const std::string &name, const std::string &value) override {
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
		} else if (name == "include-directory")
			g_IncludeDirs.push_back(value);
		else if (name == "include")
			g_IncludeScripts.push_back(value);
		else if (name == "asset")
			add_game_asset_to_bundle(value);
		else if (name == "asset-document")
			add_game_asset_to_bundle(value, GAME_ASSET_DOCUMENT);
		else if (name == "set")
			defineSetting(value);
		else if (name == "settings")
			loadConfiguration(value);
		else if (name == "platform")
			g_platform = value;
	}
	void defineSetting(const std::string &def) {
		// Originally from Poco SampleApp.
		std::string name;
		std::string value;
		std::string::size_type pos = def.find('=');
		if (pos != std::string::npos) {
			name.assign(def, 0, pos);
			value.assign(def, pos + 1, def.length() - pos);
		} else
			name = def;
		config().setString(name, value);
	}
	void displayHelp() {
		HelpFormatter hf(options());
		hf.setUnixStyle(true);
		hf.setIndent(4); // Visually appealing vs. accessibility and usability. The latter wins.
		hf.setCommand(commandName());
		hf.setUsage("[options] script [-- arg1 arg2 ...]");
		hf.setHeader("NonVisual Gaming Toolkit (NVGT) - available command line arguments");
		hf.setFooter("A script file is required.");
		if (!config().hasOption("application.gui"))
			hf.format(cout);
		else {
			stringstream ss;
			hf.format(ss);
			message(ss.str(), "help");
		}
	}
	std::string UILauncher() {
		// If the user launches NVGT's compiler without a terminal, let them select what to do from various options provided by simple dialogs. Currently the choice selection is one-shot and then we exit, but it might be turned into some sort of do-loop later so that the user can perform multiple selections in one application run.
		std::vector<string> options = {"`Run a script", "Compile a script in release mode", "Compile a script in debug mode", "View version information", "View command line options", "Visit nvgt.gg on the web", "~Exit"};
		#ifdef NVGT_MOBILE
		options[1].insert(options[1].begin(), '\0');
		options[2].insert(options[2].begin(), '\0');
		#endif
		int option = message_box("NVGT Compiler", "Please select what you would like to do.", options, SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT);
		if (option <= 0 || option >= 7) {
			mode = NVGT_EXIT;
			return "";
		} else if (option >= 1 && option <= 3) {
			if (option >= 2) {
				// compiling, select platform
				vector<string> platforms = {"auto", "windows", "mac", "linux", "android"};
				int platform_selection = message_box("NVGT Compiler", "Please select a platform to compile for.", {format("`Host platform (%s)", Environment::osName()), "Windows", "MacOS", "Linux", "Android", "~cancel"}, SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT);
				if (platform_selection <= 0 || platform_selection > platforms.size()) {
					mode = NVGT_EXIT;
					return "";
				}
				g_platform = platforms[platform_selection - 1];
			}
			std::string script = simple_file_open_dialog("NVGT scripts:nvgt");
			if (script.empty()) {
				mode = NVGT_EXIT;
				return "";
			}
			if (option > 1)
				g_debug = option == 3;
			mode = option == 1 ? NVGT_RUN : NVGT_COMPILE;
			try {
				// Try to change to the directory containing the selected script.
				ChDir(Poco::Path(script).parent().toString());
			} catch (...) {
			} // If it fails, so be it.
			return script;
		} else if (option == 4 || option == 5) {
			mode = option == 4 ? NVGT_VERSIONINFO : NVGT_HELP;
			return "";
		} else if (option == 6) {
			mode = NVGT_EXIT;
			urlopen("https://nvgt.gg");
			return "";
		}
		return ""; // How did we get here?
	}
	virtual int main(const std::vector<std::string> &args) override {
		// Determine the script file that is to be executed.
		string scriptfile = "";
		#if defined(__APPLE__) || defined(__ANDROID__)
		scriptfile = event_requested_file(); // Files opened from external apps on MacOS, IOS, and Android do not use command line arguments.
		#endif
		if (scriptfile.empty() && (mode == NVGT_RUN || mode == NVGT_COMPILE))
			scriptfile = args.size() > 0 ? args[0] : config().hasOption("application.gui") ? UILauncher()
			             : "";
		if (mode == NVGT_EXIT)
			return Application::EXIT_OK;
		else if (mode == NVGT_HELP) {
			displayHelp();
			return Application::EXIT_OK;
		} else if (mode == NVGT_VERSIONINFO) {
			string ver = format("NVGT (NonVisual Gaming Toolkit) version %s, built on %s for %s %s", NVGT_VERSION, NVGT_VERSION_BUILD_TIME, Environment::osName(), Environment::osArchitecture());
			if (config().hasOption("application.gui"))
				message(ver, "version information");
			else
				cout << ver << endl;
			return Application::EXIT_OK;
		} else if (scriptfile.empty()) {
			message("error, no input files.\nType " + commandName() + " --help for usage instructions\n", commandName());
			return Application::EXIT_USAGE;
		}
		#ifdef __APPLE__ // When run from an app bundle
		if (!scriptfile.empty() && Path::current() == "/")
			ChDir(Path(scriptfile).makeParent().toString());
		#endif
		#ifndef __ANDROID__ // for now the following code would be highly unstable on android due to it's content URIs.
		try {
			// Parse the provided script path to insure it is valid and check if it is a file.
			if (!File(Path(scriptfile)).isFile())
				throw Exception("Expected a file", scriptfile);
			// The scripter is able to create configuration files that can change some behaviours of the engine, such files are named after the script that is to be run.
			Path conf_file(scriptfile);
			conf_file.setExtension("properties");
			if (File(conf_file).exists())
				loadConfiguration(conf_file.toString(), -2);
			conf_file.setExtension("ini");
			if (File(conf_file).exists())
				loadConfiguration(conf_file.toString(), -2);
			conf_file.setExtension("json");
			if (File(conf_file).exists())
				loadConfiguration(conf_file.toString(), -2);
			// The user can also place a .nvgtrc file in the current directory of their script or any parent of it, expected to be in ini format.
			conf_file.setFileName(".nvgtrc");
			while (conf_file.depth() > 0 && !File(conf_file).exists())
				conf_file.popDirectory();
			if (File(conf_file).exists())
				config().addWriteable(new IniFileConfiguration(conf_file.toString()), -1);
		} catch (Poco::Exception &e) {
			message(e.displayText(), "error");
			return Application::EXIT_CONFIG;
		}
		#endif
		g_scriptpath = Path(scriptfile).makeParent().toString();
		setupCommandLineProperty(args, 1);
		g_command_line_args->InsertAt(0, (void *)&scriptfile);
		ConfigureEngineOptions(g_ScriptEngine);
		if (mode == NVGT_RUN) {
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
				else
					InitializeDebugger(g_ScriptEngine);
				#endif
			}
		}
		int retcode = Application::EXIT_OK;
		if (mode == NVGT_RUN && (retcode = ExecuteScript(g_ScriptEngine, scriptfile.c_str())) < 0 || mode == NVGT_COMPILE && CompileExecutable(g_ScriptEngine, scriptfile)) {
			ShowAngelscriptMessages();
			return Application::EXIT_SOFTWARE;
		}
		return retcode;
	}
	#else
	virtual int main(const std::vector<std::string> &args) override {
		setupCommandLineProperty(args);
		std::string path_tmp;
		g_command_line_args->InsertAt(0, (void *)&path_tmp);
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
		uninit_sound();
		anticheat_deinit();
		if (g_ScriptEngine)
			g_ScriptEngine->ShutDownAndRelease();
		g_ScriptEngine = nullptr;
	}
};

// Poco::Util::Application and SDL_main conflict, macro magic in SDL_main.h is replacing all occurances of "main" with "SDL_main", including the one in nvgt's derived Poco application causing the overwritten method to not call. Hack around that. You are about to scroll past 5 utterly simple lines of code that took hours of frustration and mind pain to determine the nesessety of.
#if !defined(_WIN32) || defined(NVGT_WIN_APP) || defined(NVGT_STUB)
#undef SDL_MAIN_HANDLED
#undef SDL_main_h_
#include <SDL3/SDL_main.h>
int main(int argc, char **argv) {
	AutoPtr<Application> app = new nvgt_application();
	try {
		app->init(argc, argv);
	} catch (Exception &e) {
		#ifndef NVGT_WIN_APP
		app->logger().fatal(e.displayText());
		#else
		message(e.displayText(), "initialization error");
		#endif
		return Application::EXIT_CONFIG;
	} catch (exception &e) {
		#ifndef NVGT_WIN_APP
		app->logger().fatal(e.what());
		#else
		message(e.what(), "initialization error");
		#endif
		return Application::EXIT_CONFIG;
	}
	return app->run();
}
#else
POCO_APP_MAIN(nvgt_application); // We don't use SDL_main for windows console nvgt, POCO_APP_MAIN handles UTF16 command line arguments for us via wmain.
#endif
