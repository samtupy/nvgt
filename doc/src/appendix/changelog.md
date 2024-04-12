# Changelog
This document lists all major changes that have taken place in NVGT since we started keeping track.

## New as of 04/12/2024:
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

