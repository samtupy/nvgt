# Toolkit Configuration
One highly useful aspect of NVGT is it's ever growing list of ways that an end user can configure the engine. Whether trying to add an extra include directory, tweak an Angelscript configuration property, choose how warnings and errors are printed, deciding whether to print output on successful compilation or any number of other changes, NVGT provides various options and directives that should help you to get it functioning much closer to the way you desire.

From `#pragma` directives to command line argument syntax to configuration files, this document attempts to keep track of all such available configuration options NVGT has to offer.

## Command line arguments
NVGT's compiler program has a variety of command line arguments you can pass to it which can alter it's behavior. Some of these options can also be set in configuration files, however an explicit command line option is very likely to override any contradictory options that are in a configuration file.

Generally, these command line options are self-documenting. If you open a command prompt or terminal and just run the nvgt application directly with no arguments, you will be informed that you should either provide an input file or run `nvgt --help` for usage instructions. You can also actually just run nvgt -h

In almost all cases, command line arguments have 2 methods of invocation, both a short form and a long form. The short form of a command usually consists of just a letter or two and is easier to type, while the long form of a command is always more descriptive and thus might be suited to an automation script where you want anyone reading such a script to be able to understand exactly what they are asking NVGT to do. What form you wish to use is completely up to you. In either case you should put a space between arguments, and mixing short and long form arguments is completely fine.

The short form of an argument always begins with a single hyphen character (-) followed by one or 2 letters. For example, `-C` would tell NVGT to compile your script with debug information. Some arguments take values, in which case the value shall follow directly after the argument when using short form invocations. For example you could set the platform to compile with using the `-pwindows` argument.

On the other hand, the long form of an argument begins with two hyphens followed by what usually amounts to a few words separated by hyphens. Usually it's just one or 2 words, but could be more in rare cases. For example, `--compile-debug` would tell NVGT to compile the given script with debug information. If an option takes an argument, you use an equals (=) character to define such a value. For example `--platform=windows` would tell NVGT to compile a script for the windows platform.

Finally, a special argument, two hyphens without any following text, indicates that any further arguments should be passed onto the nvgt script that is about to run.

### Argument list
The following is a list of all available command line arguments, though note that it is best to directly run `nvgt --help` yourself encase this list is in any way out of date as nvgt's --help argument will always be more accurate because the text it prints is dynamically generated.
* -c, --compile: compile script in release mode
* -C, --compile-debug: compile script in debug mode
* -pplatform, --platform=platform: select target platform to compile for (auto|android|windows|linux|mac)
* -q, --quiet: do not output anything upon successful compilation
* -Q, --QUIET: do not output anything (work in progress), error status must be determined by process exit code (intended for automation)
* -d, --debug: run with the Angelscript debugger
* -wlevel, --warnings=level: select how script warnings should be handled (0 ignore (default), 1 print, 2 treat as error)
* -iscript, --include=script: include an additional script similar to the #include directive
* -Idirectory, --include-directory=directory: add an additional directory to the search path for included scripts
* -V, --version: print version information and exit
* -h, --help: display available command line options

## Configuration files
Both because command line arguments can become exhausting to type for every script execution for a while and because NVGT contains far too many configuration options to make command line arguments out of, NVGT also supports configuration files which can be used either on a global or a project level to further direct NVGT.

Configuration files can either be in ini, json or properties formats and are loaded from multiple locations. Values in these configuration files are usually separated into sections in some form, for example settings controlling the user interface typically go in the application subsection while directives that provide control over Angelscript's engine properties are in a subsection called scripting. The way these directives in various subsections are defined depends on the configuration format you choose, however you can use any combination of configuration formats at once to suit your needs. Though all supported configuration formats are more or less standard, you can find examples of and notes on each format below.

Configuration files at any given location have a priority attached to them to resolve directive conflicts. For example if a global configuration file and a project configuration file both contain the same option, the project file takes priority.

### Loaded configuration files
The following configuration files are loaded listed in order of priority from lowest to highest:
* config.ini, config.json and config.properties in the same directory as the nvgt application
* exe_basename.ini, exe_basename.json and exe_basename.properties in the same directory as the nvgt compiler or any parent, where exe_basename is the name of nvgt's running executable without the extension (nvgt.json, nvgtw.ini)
* .nvgtrc (ini format) in the same directory containing the nvgt script that is getting executed or in any parent
* script_basename.ini, script_basename.json or script_basename.properties in the same directory as the nvgt script about to be run, where script_basename is the name of the nvgt script without an extension (mygame.nvgt = mygame.properties)

### Supported configuration formats
NVGT supports 3 widely standard configuration formats, all of which have their own advantages and disadvantages. It is perfectly acceptable to create multiple configuration files with the same name but with different extension, all keys from all files will load and be combined. If the files nvgt.json and nvgt.ini both exist and both set the same key to a different value, however, the result is a bit less defined as to what key is actually used and typically depends on what file was internally loaded first by the engine.

It is entirely up to you what formats you want to use in your projects.

#### json
```
{"application": {
	"quiet": true
}, "scripting": {
	"compiler_warnings": 1,
	"allow_multiline_strings": true
}}
```
Likely the most widely used and most modern, NVGT can load configuration options from standard JSON formatted input.

This format receives the most points for standardization. Included directly within many higher level programming languages as preinstalled packages or modules, this is the easiest format to use if you need some code to generate or modify some configuration options used in your program. For example, a python script that prepares your game for distribution might write a gamename.json file next to your gamename.nvgt script that modifies some Angelscript engine options or changes debug settings before release, and sets them to other values during development.

Furthermore if NVGT ever includes an interface to set some of these options in a manner where they save, .json files would be the format written out by the engine.

The disadvantage to JSON though is that even though it is the most modern and widely recognised of nvgt's options, it's relatively the least human friendly of the formats. For example if a configuration option takes a path on the filesystem and one wants to manually set this option in NVGT, they would need to escape either the slash or backslash characters in the path if they go with the JSON option. Furthermore NVGT contains many boolean options that are just enabled by being present, where an option key has no needed value. While JSON of course supports setting a value to an empty string, it is certainly extra characters to type in order to just quickly tweak an NVGT option.

#### ini
```
[application]
quiet

[scripting]
	compiler_warnings = 1
	allow_multiline_strings
```
NVGT can also load configuration data from good old ini formatted text files.

This format is probably the least standardized of the ones NVGT supports, likely due to it's origin from closed source windows. While on the surface it is a very simple format, there are a few deviations that exist in various parsers as the syntax is not as set in stone as other formats. For example whether subsections can be nested, whether strings should be quoted, whether escaping characters is supported or whether a value is required with a key name are all up to an individual ini parser rather than a mandated standard. In this case, the ini parser that handles these configuration files does not require that a value be provided with a key name for simple boolean options, escaping characters is not supported and strings do not need to be quoted.

The biggest advantage to this format as it pertains to NVGT is the simplicity of setting several options in the same section without constantly redeclaring the sections name. One can just declare that they are setting options in the scripting section and can then begin setting various engine properties without typing the name "scripting" over and over again for each option.

The biggest disadvantage to this format is the inability to escape characters. For example, typing \n in a configuration string would insert the text verbatim instead of a newline character as might be expected.

#### properties
```
application.quiet
scripting.compiler_warnings=1
scripting.allow_multiline_strings
```
Finally, NVGT is able to load configuration options from java style .properties files.

The biggest advantage to this format is it's easy simplicity. The format just consists of a linear list of key=value pairs, though the =value is not required for simple boolean options that just need to be present to exist. Unlike ini, it also supports character escaping, causing \n to turn into a line feed character.

The only real disadvantage to this format over ini is the need to keep constantly redeclaring the parent section names whenever defining keys, for example you need to type scripting.this, scripting.that where as with ini and JSON you can specify that you are working within a section called scripting before adding keys called this and that.

### Available configuration options
Many options listed here do not require a value, simply defining them is enough to make them have an effect. Cases where a value is required are clearly noted.

The available options have been split into sections for easier browsing. While the method for defining options changes somewhat based on configuration format, a line in a .properties file that contains one of these options might look like application.quiet or scripting.allow_multiline_strings, for example.

#### application
This section contains options that typically control some aspect of the user interface, as well as a few other miscellaneous options that don't really fit anywhere else.

* as_debug: enables the angelscript debugger (same as -d argument)
* compilation_message_template = string: allows the user to change the formatting of errors and warnings (see remarks at the bottom of this article)
* GUI: attempts to print information using message boxes instead of stdout/stderr
* quiet: no output is printed upon successful compilation (same as -q argument)
* QUIET: attempts to print as little to stdout and stderr as possible (though this option is still a work in progress)

#### build
This section contains options that are directly related to the compiling/bundling of an NVGT game into it's final package. It contains everything from options that help NVGT find extra build tools for certain platforms to those that define the name and version of your product.

* android_home string defaults to %ANDROID_HOME%: path to the root directory of the Android sdk
* android_install = integer default 1: should Android apks be installed onto connected devices if signing was successful, 0 no, 1 ask, 2 always
* android_jaava_home string defaults to %JAVA_HOME%: path to the root of a java installation
* android_manifest string defaults to prepackaged: path to a custom AndroidManifest.xml file that should be packaged with an APK file instead of the builtin template
* android_path string defaults to %PATH%: where to look for android development tools
* android_signature_cert = string: path to a .keystore file used to sign an Android apk bundle
* android_signature_password = string: password used to access the given signing keystore (see remarks at the bottom of this article)
* linux_bundle = integer default 2: 0 no bundle, 1 folder, 2 .zip, 3 both folder and .zip
* mac_bundle = integer default 2: 0 no bundle, 1 .app, 2 .dmg/.zip, 3 both .app and .dmg/.zip
* no_success_message: specifically hides the compilation success message if defined
* output_basename = string default set from input filename: the output file or directory name of the final compiled package without an extension
* precommand = string: a custom system command that will be executed before the build begins if no platform specific command is set
* `precommand_<platform>` = string: allows the execution of custom prebuild commands on a per-platform basis
* `precommand_<platform>_<debug or release>` = string: allows the execution of custom prebuild commands on a per-platform basis  with the condition of only exicuting on debug or release builds
* postcommand = string: a custom system command that will be executed after the build completes but before the success message
* `postcommand_<platform>` = string: allows the execution of custom postbuild commands on a per-platform basis
* `postcommand_<platform>_<debug or release>` = string: allows the execution of custom postbuild commands on a per-platform basis with the condition of only exicuting on debug or release builds
* product_identifier=string default com.NVGTUser.InputBasenameSlug: the reverse domain bundle identifier for your application (highly recommended to customize for mobile platforms, see compiling for distribution tutorial)
* product_identifier_domain = string defaults to com.NVGTUser: everything accept the final chunk of a reverse domain identifier (used only if build.product_identifier is default)
* product_name=string defaults to input file basename: human friendly display name of your application
* product_version = string default 1.0: human friendly version string to display to users in bundles
* product_version_code = integer default (UnixEpoch / 60): an increasing 32 bit integer that programatically denotes the version of your application (default is usually ok)
* product_version_semantic = string default 1.0.0: a numeric version string in the form major.minor.patch used by some platforms
* shared_library_excludes = string default "plist TrueAudioNext GPUUtilities systemd_notify sqlite git2 curl": Partial names of shared libraries that should not be copied from NVGT's source lib directory into the bundled product.
* shared_library_recopy: If this is set, any shared libraries will be copied from scratch instead of only if they're newer than already copied.
* windows_bundle = integer default 2: 0 no bundle, 1 folder, 2 .zip, 3 both folder and .zip
* windows_console: when compiling for windows, build with the console subsystem instead of GUI

#### scripting
This section contains options that directly effect the Angelscript engine, almost always by tweaking a property with the SetEngineProperty function that Angelscript provides.

The result is undefined if any value is provided outside suggested ranges.

For more information on these properties, the [Angelscript custom options documentation](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_adv_custom_options.html) is a great resource. There are some engine properties shown on that page which NVGT does not support the configuration of, as a result of such properties being used internally by the engine to function properly.

* allow_multiline_strings: allow string literals to span multiple lines
* allow_unicode_identifiers: allow variable names and other identifiers to contain unicode characters
* allow_implicit_handle_types: experimentally treat all class instance declarations as though being declared with a handle (classtype@)
* alter_syntax_named_args = integer default 2: control the syntax for passing named arguments to functions (0 only colon, 1 warn if using equals, 2 colon and equals)
* always_impl_default_construct: create default constructors for all script classes even if none are defined for one
* compiler_warnings = integer default 0: control how Angelscript warnings should be treated same as -w argument (0 discard, 1 print and continue, 2 treat as error)
* do_not_optimize_bytecode: disable bytecode optimizations (for debugging)
* disallow_empty_list_elements: disallow empty items in list initializers such as {1,2,,3,4}
* disallow_global_vars: disable global variable support completely
* disallow_value_assign_for_ref_type: disable value assignment operators on reference types
* disable_integer_division: Defer to floatingpoint division internally even when only integer variables are involved
* expand_default_array_to_template: cause compilation messages which would otherwise contain something like string\[\] to instead contain array\<string\>
* heredoc_trim_mode = integer default 1: decide when to trim whitespace of heredoc strings (0 never, 1 if multiple lines, 2 always)
* ignore_duplicate_shared_interface: allow shared interfaced with the same name to be declared multiple times
* init_call_stack_size =  integer default 10: the size of the call stack in function calls to initially allocate for each script context
* init_stack_size =  integer default 4096: the initial stack size in bytes for each script context
* max_nested_calls = integer default 10000: specify the number of nested calls before a stack overflow exception is raised and execution is aborted
* max_stack_size = integer default 0 (unlimited): the maximum stack size in bytes for each script context
* max_call_stack_size = integer default 0: similar to max_nested_calls but can possibly include calls to system functions (angelscript docs is unclear)
* private_prop_as_protected: private properties of a parent class can be accessed from that class's children
* property_accessor_mode = integer default 3: control the support of virtual property accessors (0 disabled, 1 only for c++ registrations, 2 no property keyword required, 3 property keyword required)
* require_enum_scope: access to enum values requires prepending the enum name as in enumname::enumval instead of just enumval
* use_character_literals: cause single quoted one-character string literals to return an integer with that character's codepoint value

## `#pragma` directives
In a few cases, it is also possible to configure some aspects of NVGT's behavior directly from within nvgt scripts themselves using the `#pragma` preprocessor directive.

This directive is used to safely tell the engine about anything that doesn't directly have to do with your script code but also without causing some sort of compilation error due to bad syntax. A pragma directive could do anything, from embedding a file to selecting assets to choosing  to adding include directories and more.

The syntax for a pragma directive looks like `#pragma name value` or sometimes just `#pragma name` if the option does not require a value. In some cases when a value is to contain a long or complex enough string such as a path, you may need to surround the value in quotes such as `#pragma name "value."`

### Available directives
* `#pragma include <directory>`: search for includes in the given directory (directive can be repeated)
* `#pragma stub <stubname>`: select what stub to compile using (see remarks at the bottom of this article)
* `#pragma embed <packname>`: embed the given pack into the compiled executable file itself
* `#pragma asset <pathname>`: copy the given asset/assets into the bundled product as resources
* `#pragma document <pathname>`: copy the given asset/assets into the bundled product as documents intended for the user to access rather than the programmer
* `#pragma plugin <plugname>`: load and activate a plugin given it's dll basename
* `#pragma compiled_basename <basename>`: the output filename of the compiled executable without the extension
* `#pragma bytecode_compression <level from 0 to 9>`: controls the compression level for bytecode saved in the compiled executable (0 disabled 9 maximum)
* `#pragma console`: produce the compiled executable on windows using the console subsystem for CLI based programs

## Remarks on complex options
This section contains any explanations of topics that were too bulky to fit in the documentation of each specific configuration option or article section.

### application.compilation_message_template
This useful option allows you to control the format that errors and warnings are printed in. The default template looks like this, for example:

`file: %s\r\nline: %u (%u)\r\n%s: %s\r\n`

Most specifically, the format string is passed to the function Poco::format in the c++ codebase, and that function receives 5 dynamic arguments. string file, uint line, uint column, string message_type, string message_content.

It is not needed to understand how this c++ string formatting function works to customize the message template however, you can just reorder the arguments and add text to the following example template:

`%[1]u %[2]u %[0]s; %[3]s: %[4]s`

This example moves the line number and column to the beginning of the string, before printing the filename, the message type and the content all on a single line. NVGT automatically adds one new line between each engine message printed regardless of the template.

### platform and stub selection
One possible area of confusion might be how the platform and stub directives fit together. In short, the stub option lets you choose various features or qualities included in your target executable while platform determines what major platform (mac, windows) you are compiling for.

Though explaining how NVGT's compilation process works is a bit beyond the scope of this article, the gist is that Angelscript bytecode is attached to an already compiled c++ program which is used to produce the final executable. There are several versions of the c++ program (we call that the stub) available with more that could appear at any time. For example a stub called upx will produce an executable that has already been compressed with the UPX executable packer, while a stub available on windows called nc will insure that the Angelscript compiler is not included in your target application. In the future we hope to include several more stubs such as one focusing much more on performance over file size, one focusing on minimal dependencies to insure no third party code attributions are needed, etc.

Internally, you can see this at play by looking in the stub directory of NVGT's installation. You can see several files with the format `nvgt_<platform>_<stubname>.bin`, or sometimes just `nvgt_<platform>.bin` which is the default stub for a given platform. Such files are used to create the final game executable produced by NVGT's compiler, and are selected exactly using the configuration pragmas and options described. If platform is set to windows and stub is set to nc, the file nvgt_windows_nc.bin is used to produce the compiled executable of your game. The only exception is if the platform is set to auto (the default), which will cause your executable to be compiled for the host platform you are compiling on.

### bundle naming and versioning
NVGT includes several directives particularly in the build configuration section that allow you to control how your product is identified to end users and to the systems the app is running on. While some are purely for display, others are manditory in certain situations especially when you plan to distribute your app on networks like the app store, google play and similar. For more info on these directives, you should read the "configuring bundling facility" section of the compiling for distribution topic.

## Conclusion
Hopefully this tutorial has given you a good idea of how you can get NVGT to perform closer to how you would like in various areas from the user interface to the syntax handling. If you have any ideas as to configuration options you'd like to see added, please don't hesitate to reach out on github either with a discussion or pull request!
