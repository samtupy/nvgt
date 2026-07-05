/* bundling.h - header containing interface to app bundling routines
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#pragma once
#include <string>
#include <vector>

// Game asset management.
enum game_asset_flags { GAME_ASSET_DOCUMENT = 1 << 0, GAME_ASSET_BINARY = 1 << 1, GAME_ASSET_UNCOMPRESSED = 1 << 2 };
void add_game_asset_to_bundle(const std::string& filesystem_path, const std::string& bundled_path, int flags = 0);
void add_game_asset_to_bundle(const std::string& path, int flags = 0);

// Thread-safe message box for use in the bundling system. Dispatches to the main thread via SDL_RunOnMainThread and blocks until the result is available, allowing it to be called safely from worker threads such as during compilation. For multi-button (question) dialogs, returns -1 without showing anything when either application.quiet is set or is_console_available() returns true, since the user cannot interactively answer such dialogs in those modes. For single-button alerts in console mode, prints title/text to stdout instead of showing a dialog.
int nvgt_compile_message_box(const std::string& title, const std::string& text, const std::vector<std::string>& buttons);

// The following class has a specific use case in which prepare, write_payload, and finalize are expected to be called once and in order. Ignoring these conditions will result in negatively undefined behavior. finalize() handles all post-build steps including platform packaging, the success dialog, and any final install steps. The class will throw exceptions on error and if this happens, the failed object instance should be discarded. This class is also expected to be used from a standalone thread, with the get_status() function being called in a loop on the main thread for updates. Usage is in CompileExecutableTask (angelscript.cpp).
class nvgt_compilation_output {
public:
	virtual ~nvgt_compilation_output() {}
	virtual void prepare() = 0; // Copies the configured stub and opens the copy for writing the payload, allowing for any per-platform handling during the process such as extracting nvgt_android.bin (a zip file) then opening the contained libgame.so, just directly opening nvgt_windows.bin (an executable) for writing, or anything else in between so long as write_payload can then be safely called.
	virtual void write_payload(const unsigned char* payload, unsigned int size) = 0; // This also takes care of writing embedded packs.
	virtual void finalize() = 0; // Does anything necessary per platform to take the now prepared output executable or binary and bundle it into a package that is as ready to be run by an end player to the best extent NVGT can manage, usually driven by several configuration options. This might do anything from copying shared libraries to preparing an entire app bundle depending on platform and configuration. Also displays the compilation success dialog and handles any final post-build steps such as installing the build on a connected device.
	virtual void set_status(const std::string& mesage) = 0; // Sets a status message that gets picked up by get_status below in a thread-safe manner, used for the compilation status display.
	virtual std::string get_status() = 0; // Returns the last status message set using set_status, and clears the status buffer. Must be called in a loop from a different thread than that on which set_status was executed.
	virtual const std::string& get_error_text() = 0;
	virtual const std::string& get_output_file() = 0;
};
nvgt_compilation_output* nvgt_init_compilation(const std::string& input_file, bool auto_prepare = true);
