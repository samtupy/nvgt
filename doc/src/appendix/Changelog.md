# Changelog
This document lists all major changes that have taken place in NVGT since we started keeping track.

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

