# Changelog
This document lists all major changes that have taken place in NVGT since we started keeping track.

## New as of 06/02/2024:
*     The form and speech includes no longer require  bgt_compat!
* adds sound_default_pack property.
    * For example, you can now create a pack object, execute the expression @sound_default_pack = my_pack; and from that point all sounds in the engine will use the default pack you have set unless you explicitly override it.
* Modified number conversion in sound mixer classes to use more efficient string -> number handling
* Fixed typo in doc for BSL license
* Start on pack object docs
* include form.nvgt in speech by default.
*     Astyled number_speaker.nvgt
* Add includes/number_speaker.nvgt; makes it very easy to self-voice numbers!
* Many more internal tests that basically mean lots of stuff should be much faster!

## New as of 05/31/2024:
* complete rewrite of NVGT entry point to use a Poco application. This includes much cleanup and organization and adds several features:
    * There is now proper command line parsing, help printing, config file loading for when we want to use it, and more.
    * This also introduces the change that on windows, there is now nvgt.exe and nvgtw.exe that gets built, one with the windows subsystem and one without.
    * Script files and nvgt's binary will check for config files with the basename of file + .ini, .properties, or .json.
* The above changes mean that we now implement the Angelscript debugger since the nvgt compiler is now always available in console mode.
* NVGT now uses simantic versioning, for example 0.85.0.
* Fixed script return code.
* NVGT finally has a cross-platform installer (NSIS on Windows and a .dmg file on macOS).
* The timer class once present in `bgt_compat.nvgt` is finally in the core of the engine!
* it is now possible to embed packs into executables! 
* The way Windows binaries load has been changed, meaning that UPX or any other binary compresser that supports overlays can now be used on your compiled NVGT binaries!
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
* NVGT now has a build system! I know it's not the fastest one around, but needing a  middleground between learning even more new things and using what I already know, I chose SCons purely because of the fermiliar pythonic environment and not needing to learn yet another new set of syntax rules. I'm just glad we're no longer building the engine using a series of shell scripts!
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
* Better multithreading support with more primatives.
* More functions in the string class.
* New methods of operating system detection.
* Instance class removed from engine and replaced with include/instance.nvgt which wraps a named_mutex.
* Regular expressions now use PCRE2 via poco including lower level regexp class.
* Alert and question now use SDL message boxes (not sure what I think of this).
* Other misc changes.

## Note for changes before 01/06/2024:
Changes were roughly untracked before this time, but there is a rather large list of somewhat sorted changes below as commited to nvgt_bin (a repository where the NVGT testers could access and test NVGT). These are sorted by month where possible to make them easier to sort, but keep in mind that commits to nvgt_bin usually occurred all at once so that building NVGT was easier for all platforms. As such, expect these lists (while somewhat sorted) to become rather large! Additionally, some of these changes may be ambiguous due to being based off of nvgt_bin's commit messages only. At this time, it was assumed anyone using this engine had direct contact with Sam to ask questions.

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
* Fixed vector devision scaling operators.
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

