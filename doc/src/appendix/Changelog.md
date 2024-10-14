# Changelog
This document lists all major changes that have taken place in NVGT since we started keeping track.

## New in 0.89.1-beta (10/09/2024):
* Fixes copying of shared libraries while bundling on MacOS which was resulting in an assertion violation from Poco.
* Fixes MacOS not changing to the directory of scripts launched from finder or the open command.
* Hopefully we've finally resolved all of the MacOS includes resolution issues, there should be no more manually adding include paths to your scripts or command line invocations!
* Fixes the enter key not pressing the default button in audio form lists.
* Linux cross compilation should work again, the Linux build script was pulling down the wrong version of Angelscript.
* `#pragma platform` has been deprecated, you should use the command line / menu options / UI to specify platforms instead.
* Adds preprocessor macros to check platform! You can surround code in `#if android ... #endif` for example, or `#if_not windows ... #endif` as well. You can even use this to specify custom includes or pragmas just on certain platforms.

## New in 0.89.0-alpha (10/09/2024):
* NVGT has now switched to using InnoSetup for it's installer, adding several new options such as adding to path, start menu icons etc.
* Added the script_function::get_namespace() method as well as script_function::retrieve() which takes a native function handle derived from a funcdef.
* Including pack files via the `#include` directive has been removed in favor of being able to include scripts of any extension, you should use the `#pragma embed` directive to do this instead.
* NVGT games now run on intel as well as arm mac computers!
* The calendar object is now registered as a reference type with Angelscript meaning it now supports handles, for BGT backwards compatibility. The other datetime classes are still value types.
* Added bool sdl_set_hint(const string&in hint, const string&in value, sdl_hint_priority priority = SDL_HINT_NORMAL) and string sdl_get_hint() functions, allowing the user to customize over 200 different SDL options from screen orientation to the video backend used and many more.
* Adds atomic types, or in other words more concurrency primitives.
* The array class can now work with negative indicies to access elements starting at the end of arrays, For example `array[-1]` now returns the last element in the array.
* Registered SYSTEM_PERFORMANCE_COUNTER and SYSTEM_PERFORMANCE_FREQUENCY properties as well as nanosleep and nanoticks functions, still needs documentation.
* ini.nvgt include is now free of bgt_compat! Added quick test for it.
* Fixed a bug in instance.nvgt include regarding automatic mutex name generation.
* The compiler now includes a status window that continues getting updated with messages reporting what is currently happening during compilation.
* Adds refresh_window() function, allowing manual pulling for windows events encase you want to use your own sleeping methods.
* Adds input_forms.nvgt include with functions to quickly retrieve information using an audio form, test/example in test/interact/test_input_forms.nvgt.
* Introduce new menu system based on audio form, in menu.nvgt. As a result, the old dynamic menu has been renamed to bgt_dynamic_menu.nvgt to make it clear what one is legacy.
* Registered some new vector functions such as cross, length2, distance and distance2 etc.
* datastream.available is now an uint64 rather than int.
* The ghost settings object in bgt_compat.nvgt was removed, as a new settings.nvgt include was contributed to the project! While the new settings object does not currently support the windows registry, this is made up for by several useful features such as encryption, data format selection, default values and more. You can read the top of settings.nvgt for a full list of changes. The new settings.nvgt script is `#included` by default in bgt_compat to avoid any compatibility issues.
* Though this effort is still somewhat on going, most parameters of NVGT's builtin functions and methods have been properly named. Not only does this mean that passing named arguments works, but it is also a small step closer to a VSCode or similar plugin.
* screen_reader_output/speak now have their interrupt booleans set to true by default.
* Though a more advanced (multi-selection / non-blocking) API for this will be added in the future, simple open_file_dialog, save_file_dialog, and select_folder_dialog functions have now been added.
* There are now 2 new functions which have yet to be documented, bool simulate_key_down(uint key) and bool simulate_key_up(uint key). These directly post SDL keydown/up events to the event queue.
* Any key_up events with matching keycodes as any key_down event in the same frame will now be moved to the next frame. This previously only happened with a few specialized events (namely voice over arrow keys and windows clipboard history), but now this is done in all scenarios meaning that the Mac touch bar and other on screen or touch based keyboards should now function properly.
* adds is_console_available function.
* Fixed a serious bug in pack::add_memory that caused adding large files to usually fail.
* Adds the `string generate_custom_token(int token_length, string characters);` function to token_gen.nvgt include.
* Add virtual_dialogs.nvgt include.
* Add datastream.sync_rw_cursors property (true by default).
* tts_dump_config and tts_load_config in speech.nvgt include can now save screen reader usage setting.
* ADDED ANDROID PLATFORM SUPPORT, NVGT RUNS ON MOBILE! This includes gesture detection (touch.nvgt include or query_touch_device function), screen reader speech through Android's accessibility event API, and android TextToSpeech engine support through  the tts_voice class! The support is still young and there are many improvements still to be made (only the default tts voice can be used right now and the only way to embed sounds is by using the `#pragma embed pack.dat` feature for example), but even running small nvgt scripts from source is possible at this point with NVGT's Android runner application, and one-click APK bundling is possible!
* NVGT now has a bundling facility! It can create .apk packages for android (assuming the needed android tools are available), it can create MacOS app bundles on all platforms though only a .dmg on Mac (.app.zip on other platforms), and it can copy Windows/Linux libraries into place as well as bundle your asset files like sounds, readme and changelog all to create a fully distributable package in one click! It can even run custom prebuild and postbuild shell commands in case the bundling facility isn't quite doing enough for your needs. More information is in the compiling for distribution document. This means as an aside that NVGT's compiler application is significantly larger, as it must include the MacOS and Linux libraries on windows, the Windows and Linux libraries on Mac etc for the purposes of creating a fully functional app bundle no matter what platform it is compiled on.
* The compile script submenu has changed, it now contains options to compile for all platforms you have stubs for!
* Trying to embed a pack that doesn't exist no longer makes NVGTW.exe silently exit.
* Added the is_window_hidden function.
* NVGT's UI application now has a launcher dialog instead of informing the user that no input file was provided. You can run scripts, compile scripts including platform selection, or do a few other things such as viewing the command line arguments/version information.
* The directory_delete function now includes a recursive boolean argument.
* Upgrades NVGT to SDL3!
* Switched to UniversalSpeech static, no more Tolk.dll required for screen reader output!
* form.nvgt modifications:
    * The `form::is_disallowed_char` method will now always return true if the character is not allowed. This also automatically checks whether the control index is being used as either blacklist or whitelist, the `use_only_disallowed_characters` parameter.
    * Pasting text will now fail if the clipboard contains disallowed characters.
    * Fixes a bug regarding the go to line dialog and the column being set 1 character to the left from where it should be.
    * Adds the ability to create custom control type labels.
    * Added Link control type.
    * If you alt tab to the application from another program while in an audio form, it reannounces the current focus control.
    * Added Floating points support in sliders and Fixed home/end bug with sliders.
    * Adds set_list_properties method.
    * Added word deletion.
    * You can now serialize the `audioform_keyboard_echo` property.
    * Once an input field is popped out, You can use the F2 key to change between echo modes. The changed echo mode will be spoken out loud, as well as updating the `audioform_keyboard_echo` property.
    * The `reset` method now takes a new parameter, true by default, which resets the form's echo mode to default. This is useful to retrieve the value of the `audioform_keyboard_echo` property.
    * The go to line functionality can now be used on non multiline input fields as well. In non multiline fields, the line number field will be invisible.
    * Added a new method that allows you to toggle the go to line functionality. `bool set_enable_go_to_index(int control_index, bool enabled);`
* Added a new parameter in sound_pool's `update_listener_3d` function called `refresh_y_is_elevation` (bool) which toggles whether the sound pool should refresh the global `sound_pool_default_y_is_elevation` property. This makes it possible to constantly change the global property for the sound elevation.
* token_gen.nvgt can now generate different token types, see the `token_gen_flag` enum.
* Add string::is_whitespace method.
* Fix small memory leak in pathfinder due to not releasing callback data reference on path calculation failure.
* Add SCRIPT_BUILD_TIME property.
* Fixes missing const qualifier in mixer::set_fx which was causing random memory corruption on some systems and in some situations.
* Slightly improves include path resolution when running nvgt scripts on Macos.
* Speed improvements to find_files and find_directories especially on windows.
* Datastreams can now be implicitly created from strings.
* Add var::opCmp method.
* Documentation:
    * Updates compiling for distribution tutorial to talk about bundling facility.
    * Talk about Angelscript addons and delayed dll loading in plugin creation tutorial.
    * Documents TIMEZONE_* properties and refresh_window() function, update wait.nvgt to indicate that it calls refresh_window().
    * Document settings.nvgt include.
    * Document the number_speaker.nvgt include.
    * Partially document timestamp class, still needs operators and maybe a couple other things.
    * Completely documented thread_event class as well as concurrency enums.
    * update datetime property examples to say "set thing" instead of "current thing," document julian_day property.
    * Documents timestamp_from_UTC_time function.
    * Documents thread_current_id and thread_yield.
    * documents sound_global_pack property.
    * Various minor polishing for a few functions in data manipulation, audio, and user interface.
    * documented set_application_name, focus_window, is_window_hidden, and get_window_text. Also removed joystick_count from the documentation as it was an old SDL2 function.
    * Update pack documentation to note a confusion with get_file_offset vs. offset parameter as well as fixing inconsistent parameter name in read_file.
    * Added many more docs for the pack object, documented file_copy function.
    * Updates toolkit configuration tutorial to include all new options.
    * Added a note in the introduction topic that indicates the incomplete state of the docs.
    * Update contributors.
    * Array: `insert_at`, `remove_at`, most other methods with their examples.
    * dictionary, almost everything accept the indexing operator.
    * Environment global properties: `PLATFORM`, `PLATFORM_DISPLAY_NAME`, `PLATFORM_VERSION`, `system_node_name`, and `system_node_id`.
    * file datastream, including write method in the datastream documentation.
    * Token Gen documentation updated, including its enum constants.
    * Adds a not yet complete memory management tutorial.
    * Todo updated.
    * Fixed return type of network::connect and resolve syntax error in tts_voice constructor reference, other various syntax and formatting.
    * Audio game development tutorial has been slightly updated.
    * audio_form documentation is now mostly complete.

## New in 0.88.0-beta (07/01/2024):
* several improvements to the audio form:
    * fix the go to line dialog, it had broken a few versions ago when converting the form to no longer need bgt_compat.
    * adds method `bool is_disallowed_char(int control_index, string char, bool search_all=true);` which checks whether the given characters are allowed. It is also possible to make the search_all parameter to true or false to toggle whether the method should search to match full text, or every character. You can also omit the control_index parameter, in which case the method is used internally in the control class.
    * adds method `bool set_disallowed_chars(int control_index, string chars, bool use_only_disallowed_chars=false, string char_disallowed_description="");` which sets the disallowed characters in a given control. Setting the use_only_disallowed_chars parameter to true will restrict to use only characters that have been set into this list. The char_disallowed_description parameter is also optional and sets the description or the text to speak when the user types the character that isn't allowed. Default is set to empty, meaning there will be silent when the user types the not allowed character. Setting the chars parameter to empty string will clear the list, thus setting to its original state.
    * Adds methods is_list_item_checked and get_checked_list_items, also made the get_list_selections function return a handle to the array.
    * Add a type of list called tab panel. This does not include the ability to assign controls to each tab automatically right now, but instead just the facility to create a list that acts more like a tab control.
* adds blocking functions to and exposes the pause functionality in the music manager include.
* adds a boolean to sound.play (true by default) which controls whether to reset the loop state on sound resume, so it's now possible to pause a looping sound and resume it without knowing whether the sound loops.
* add functions to var type such as is_integer, is_boolean, is_string and more to determine what is stored in the var, also var.clear().
* Added `sound_pool_default_y_elevation` property into sound_pool. This property will be useful to set default `y_is_elevation` property of each sound pool without having to change later for every sound pool you declare. Note, however, that it will only work for sound_pools declared after the variable is set, for example a global sound_pool variable will likely initialize before any function in your code could set the property.
* improve passing arguments to async calls.
* Fix critical bug if using network_event by handle that could allow the static none event to get value assigned to! Also better type info caching during the creation of some arrays.
* improve the speed of stream::read() when the stream size can be determined, which can be done automatically for files.
* users should no longer need to install libgit2 and openssl in order to run NVGT games on MacOS!
* Implement the recently contributed AVTTSVoice class into nvgt's tts_voice object, meaning we now have AVSpeechSynthesizer support for MacOS in NVGT! Temporary caveats:
    * Though this works well enough for people to start playing with, it still needs more testing. In particular, too much switching of voices followed by speech could cause a tts_voice object to break, calling refresh would probably fix it. Exact condition to reproduce unknown.
    * We also still need to figure out how to clamp the MacOS rate/pitch/volume parameters into the -10 to +10 that is typically used in the tts_voice class, so parameter adjustment may be rough for a short time.
    * The contributed class provides methods to handle languages, but the nvgt tts_voice class does not yet have these, as such voices just have raw names for now until we brainstorm more API.
    * For now this class speaks using the operating system directly and does not interact with bass, and so speak_to_memory is not yet supported. This will be addressed as the AVSpeech API does give us methods to do this.
* It is now possible to open .nvgt scripts directly within finder with the MacOS app bundle!
* array.insert_last can now take a handle to another array.
* Documentation:
    * major spell checking session as well as some formatting.
    * array::insert_last method.
    * sound::loaded_filename method.
    * string::format method.
    * get_characters function
    * idle_ticks function.
    * mutex class
    * concurrency article
    * Game programming tutorial updates
    * Clarifies some information in the distrobution topic.
    * Include direct links to MacOS and Linux build scripts.
    * Minor updates to contributors topic.
    * Updates to the todo and bgt upgrading topics.

## New in 0.87.2-beta (06/17/2024):
* Hopefully removed the need for the user to run `xattr -c` on the mac app bundle!
* Fix an accidental UTF8 conversion issue introduced into screen reader speech that took place when implementing speech dispatcher.
* NVGT will no longer fail if a plugin pragma with the same plugin name gets encountered multiple times.
* Fix minor error in bgt_compat's set_sound_storage function where the filename stored was not caching for display properly.
* Improve the downloads page to include release dates and headings for old versions as well as file sizes, yes we do still intend to integrate with github releases.
* Fix the broken SCREEN_READER_AVAILABLE property on windows.
* New documentation on compiling a game for distribution.

## New in 0.87.1-beta (06/16/2024):
* This patches an issue with the speech dispatcher support on linux where calling screen_reader_unload() would cause a segmentation fault if it had not loaded to begin with due to no libspeechd being available.
* Fixed a severe lack of debugging information issue where if a plugin could not load on linux, no error information was printed and instead the app silently exited.
* Fix an issue where some error messages that printed to stdout were not following up with a new line.
* Another enhancement to the network object which avoids an extra memory allocation every time a network_event of type event_none was created.

## New in 0.87.0-beta (06/16/2024):
* The jaws keyhook works even better than it did before and is nearing full functionality, though you may still need to alt+tab a few times in and out of the game window if JAWS restarts.
* Various improvements to the network object:
    * added packet_compression boolean which allows the user to toggle enet's builtin packet compressor allowing nvgt network objects to be backwards compatible with BGT if this is enabled!
    * Added packets_received and packets_sent properties.
    * network.destroy takes an optional boolean argument (flush = true) which can make sure any remaining packets are dispatched before the host is destroyed.
    * bytes_received and bytes_sent properties no longer wrap around after 4gb due to enet tracking that information using 32 bit integers.
* Add support for speech dispatcher on Linux and other BSD systems!
* You can now use the directive `#pragma embed packname.dat` as an alternative to `#including` your pack files.
* Fix broken quoted strings when handling pragma directives, resolving issues with the `#pragma include` option.
* Mostly finishes making it possible to configure various Angelscript engine properties as well as other NVGT options using configuration files, just needs polishing.
* bgt_compat's string_to_number function now trims whitespace to comply with bgt's standard, our new faster parse_float doesn't do that anymore in the name of performance.
* Fix issues with sound::push_memory():
    * actual audio files can be pushed to the function without modifying any other arguments other than the data string.
    * Calling sound.load() with a blank filename is no longer required before push_memory functions.
* Some polishing to the Angelscript integration:
    * If a global variable fails to initialize, the exception that caused it is now properly shown in the compilation error dialog.
    * There should hopefully be no more cases where a compilation error dialog can show up after a script executes successfully and throws an exception. Instead if the user enables the warnings display, they should properly see warnings before the script executes.
    * Set up the infrastructure to be able to store a bit of extra encrypted information along side the bytecode payload in compiled programs, for now using that to more securely store the list of enabled plugins as well as the serialized Angelscript properties.
    * Scripts no longer compile if they do not contain a valid entry point.
* Updated to the latest Angelscript WIP code which resolves a bytecode load error that had been reported.
* Revert the code changes to mixer::set_fx back to NVGT's first public release as the refactor did not go well and continued introducing unwanted side effects.
* Fixed bugs in find_directories and find_files on Unix platforms, the functions should now behave like on windows.
* Adds idle_ticks() function (works on windows and MacOS at present) which returns the number of milliseconds since the user has been idle.
* Update Angelscript's script builder addon which makes it possible to use unicode characters in script include paths.
* Add multiplication operators to strings, for example `string result = "hello" * 10;`
* There is a new way to list files and directories, a function called glob. Not only can it return all files and directories in one call, but you can even provide wildcards that enter sub directories. The function is documented in the reference.
* New additional version of json_array and json_object.stringify() which takes a datastream argument to write to.
* json_array and json_object now have get_array and get_object methods that directly return casted json_array@ or json_object@ handles.
* Added default_interrupt property in the high level Speech.nvgt include to set default interrupting for all the speech.
* Documentation: configuration tutorial, much of tts_voice object and other minor improvements.

## New in 0.86.0-beta (06/08/2024):
* running nvgtw.exe or the mac app should now show a message box at least rather than silently exiting.
* Improves the functionality of the JAWS keyhook. We likely still have more to go before it's perfect, but it is at least far better than it was before.
* pack::open is now set to read mode by default and will try closing any opened pack rather than returning false in that case.
* Added sound.loaded_filename property to determine the currently loaded filename of a sound object.
* Added string.reserve() function.
* Added  get_window_os_handle() function.
* Fix issues in sound::set_fx in regards to effect deletion.
* NVGT's datetime facilities now wrap Poco's implementations. Documentation is not complete, but the 4 new classes are datetime, timestamp, timespan, and calendar (which wraps LocalDateTime) in Poco and is called calendar for bgt backwards compatibility. Global functions include parse_datetime, datetime_is_leap_year and more, and all classes include a format method to convert the objects into strings given a format specifier.
* Converted most filesystem functions to wrap Poco's implementations.
* Fix potential issue with network where packets don't destroy on send failure.
* Added string_create_from_pointer to library functions.
* Though the sound pool will soon be superseded by better methods of handling sounds, it has received various improvements nevertheless:
    * Add y_is_elevation property. When this is set to false, the positioning works as normal, E.G. x is left/right, y is back/forward, and Z is up/down. When it's set to true, y is now up/down and Z is back/forward. This is useful for 2D platforming games for example, or games where y is up/down and Z is back/forward rather than the reverse. At some point this will be built into the engine so that it can be used on sound objects directly.
    * Fix a bug when using the new sound_default_pack global property.
    * Cleaned up the constructors and play_extended functions a bit.
    * bgt_compat.nvgt is no longer required to used this include.
* Adds a new function to dynamic_menu (add_multiple_items) that accepts an array of arrays. Each subarray must have at least 1 element. The first element is the text, the second element is the name. (#31)
* Fix a couple of issues in the url_post implementation.
* Register the Angelscript math complex addon.
* fix missing include of bgt_compat in dynamic_menu.nvgt
* fix number_to_words implementation appending null character to the end of it's output string
* Adds a set_sound_storage function to bgt_compat.nvgt which takes advantage of the new sound_default_pack property.
* Still a long long ways to go, but minor docs updates and a couple of new test cases.

## New in 0.85.1-beta (06/03/2024):
* The restart method on timers will now unpause them.
* Dramatically increase the speed of floating point string parsing.
* The form and speech includes no longer require  bgt_compat!
* adds sound_default_pack property.
    * For example, you can now create a pack object, execute the expression @sound_default_pack = my_pack; and from that point all sounds in the engine will use the default pack you have set unless you explicitly override it.
* Modified number conversion in sound mixer classes to use more efficient string -> number handling
* Fixed typo in doc for BSL license
* Start on the documentation for the pack object
* include form.nvgt in the speech.nvgt include by default.
* Add includes/number_speaker.nvgt (a port of bgt's class); makes it very easy to self-voice numbers!
* There are now a few more test cases as well as the beginnings of a benchmarking framework which will begin leading to several speed improvements such as the floating point processor mentioned above!

## New as of 05/31/2024:
* complete rewrite of NVGT entry point to use a Poco application. This includes much cleanup and organization and adds several features:
    * There is now proper command line parsing, help printing, config file loading for when we want to use it, and more.
    * This also introduces the change that on windows, there is now nvgt.exe and nvgtw.exe that gets built, one with the windows subsystem and one without.
    * Script files and nvgt's binary will check for config files with the basename of file + .ini, .properties, or .json.
* The above changes mean that we now implement the Angelscript debugger since the nvgt compiler is now always available in console mode.
* NVGT now uses symantic versioning, for example 0.85.0.
* Fixed script return code.
* NVGT finally has a cross-platform installer (NSIS on Windows and a .dmg file on macOS).
* The timer class once present in `bgt_compat.nvgt` is finally in the core of the engine!
* it is now possible to embed packs into executables! 
* The way Windows binaries load has been changed, meaning that UPX or any other binary compressor that supports overlays can now be used on your compiled NVGT binaries!
* The timer resolution should be much more accurate on Windows.
* Added a new, optional `uint timeout` parameter to the `network.request()` method.
* Improved documentation.

## New as of 05/25/2024:
* Wrapped `thread_pool` and `thread_event` from Poco.
* New function: `script_engine_dump_configuration()`.
* We now have an ftp_client class.
* raw memory allocation functions and memory_reader/writer datastreams to use them.
* May need more testing, but added the `async` class, for easily running a function on a thread and getting its return value.
* Many more docs.

## New as of 05/08/2024:
* Added a plugin to send notifications to systemd on Linux.
* Many more docs.
* `string.split()` should now reserve memory properly.
* Wrapped Poco for HTTP/HTTPS requests.
* Fix ancient bugs in soundsystem including too many functions registered as const and `close()` returning true on no-op.

## New as of 04/18/2024:
* The var type now has PostEnc and PostDec operators.
* UTF8 fixes: sound.load, and compiled applications can now execute if they contain non-english characters in their filenames.
* All code that I wish to share has been forked into what will hopefully be nvgt's long-standing repository which will eventually have it's privacy status switched to public!
* NVGT now has a build system! I know it's not the fastest one around, but needing a  middle ground between learning even more new things and using what I already know, I chose SCons purely because of the familiar pythonic environment and not needing to learn yet another new set of syntax rules. I'm just glad we're no longer building the engine using a series of shell scripts!
* Added basic steam audio reverb integration! It needs a lot of work and is far from being production ready (seriously this could slow your game to a crawl until I'm done with this), but nevertheless it is still around for testing!

## New leading up to 02/20/2024:
* NVGT now finally has a documentation structure!
* Unifying the file object into stream classes.

## New as of 01/06/2024:
* Misc sound system improvements (including the ability to set the pitch of a sound as low as 5).
* Fix memory leak.
* Remove sound_environment class for now.
* Should load bassflac.dll and bassopus.dll if present
* JSON Support.
* Better multithreading support with more primitives.
* More functions in the string class.
* New methods of operating system detection.
* Instance class removed from engine and replaced with include/instance.nvgt which wraps a named_mutex.
* Regular expressions now use PCRE2 via poco including lower level regexp class.
* Alert and question now use SDL message boxes (not sure what I think of this).
* Other misc changes.

## Note for changes before 01/06/2024:
Changes were roughly untracked before this time, but there is a rather large list of somewhat sorted changes below as committed to nvgt_bin (a repository where the NVGT testers could access and test NVGT). These are sorted by month where possible to make them easier to sort, but keep in mind that commits to nvgt_bin usually occurred all at once so that building NVGT was easier for all platforms. As such, expect these lists (while somewhat sorted) to become rather large! Additionally, some of these changes may be ambiguous due to being based off of nvgt_bin's commit messages only. At this time, it was assumed anyone using this engine had direct contact with Sam to ask questions.

## New as of 12/10/2023:
* Using more poco libraries including basic json implementation.
* Improvements to the sound crash.
* Fixes instances where the engine was not handling UTF8 properly.
* Performance increases such as updated hashmap and making network object faster.
* First and probably unstable implementation of a plugin system.
* Attempts to improve 3d pathfinding.
* Example of subscripting.
* More misc changes.

## New as of 07/24/2023:
* Switch to sdl2 for keyboard/windowing (new key_repeating / get_preferred_locales() / urlopen() functions as a result).
* Switch random number generators (see random_* classes).
* Fixed random_get/set_state().
* Now using Poco c++ libraries for various encode/decode/hash operations as well as better TIMEZONE_* properties and more (thus dropped cppcodec).
* UTF8 support.
* Multithreading support including mutex class.
* Library object.
* Basic msgpack support (see packet and string.unpacket functions).
* md5/sha1/sha224/sha384 hashing added as well as HOTP function (see TOTP.nvgt example).
* libgit2 support.
* Bytecode compression (#pragma bytecode_compression 0-9).
* Multiple windows stubs including Enigma Virtual Box.
* Reduced sound crashes
* Resolved a tts_voice crash.
* More misc.

## New as of 04/24/2023:
* Improvements to db_props include.
* New system information functions for custom system fingerprint or error tracking.
* Improvements to coordinate_map.
* Subscripting can now compile to bytecode.
* Fixed vector division scaling operators.
* Improved reliability of timer queue.
* Many more minor bugfixes.

## New as of 02/22/2023:
* Fixes major rotation issue
* Sqlite has more functions.
* db_props updated.
* Minor readme updates.
* scriptstuff reference issue fixes.
* Pathfinder micro speed improvement.
* file_hard_link and file_hard_link_count.
* More.

## New as of 01/17/2023:
* Sans speech and windowing, NVGT runs on Linux!
* Updated Bass/SteamAudio.
* SQLite3 wrapper.
* Improvements to subscript execution.

## New as of 10/21/2022:
* Script_module and script_function classes.
* Reduced sound crash.
* speed improvements and more.

## New as of 09/20/2022:
* Updated sound docs.
* Added sound_default_mixer property.

## New as of 09/09/2022:
* If you call the wait() function with long duration, the window no longer hangs.
* Fix string_hash() issue.
* Updated some BGT to NVGT gotchas.

## New as of 09/08/2022:
* Fixes string_split().

## New as of 09/07/2022:
* Upgrades SteamAudio to 4.11.
* Reduces sound crash.

## New as of 09/02/2022:
* Fixed bug in crypto.
* Sound crash now much more rare.
* String coordinate_map_area::type replaced with any@ coordinate_map_area::primary_data.
* Other misc.

## New as of 08/20/2022:
* print() function should now be lowercase again.
* Many very minor fixes and improvements.

## New as of 07/01/2022:
* Partially recoded pack streaming system to hopefully reduce sound crashes.
* Various random speed improvements and fixes.

## New as of 06/30/2022:
* Fixes a few speed issues with includes.
* adds ini.list_wildcard_sections().

## New as of 06/02/2022:
* Mostly works on making sound/pack more threadsafe.
* Make ini loading robust.
* Documents thread lock functions.

## New as of 05/26/2022:
* Documentation and test for include/music.nvgt.
* Updated readme a bit.
* Working on sound callbacks.
* Enabled bass_asyncfile for faster sound playback.

## New as of 05/22/2022:
* Updated INI.

## New as of 05/21/2022:
* sound.set_length() for streaming sounds.

## New as of 05/15/2022:
* Fixed run function regarding filenames with spaces.
* FTP uploads.
* MLSD directory listings with internet_request.

## New as of 05/08/2022:
* Bullet3 vectors.
* size_to_string updates.
* Other misc.

## New as of 04/26/2022:
* Sound preloading.
* byteshift encryption.
* timer_queue.exists and timer_queue.is_repeating.
* Minor speed improvements.

