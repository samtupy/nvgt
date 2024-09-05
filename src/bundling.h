/* bundling.h - header containing interface to app bundling routines
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

#pragma once

// This class has a specific use case in which prepare, write_payload, and finalize are expected to be called once and in order. Ignoring these conditions will result in negatively undefined behavior. It's functionality is split into 3 steps mostly in order to profile and/or error check at certain points or in other ways order execution from outside the class E. don't generate a payload in the first place unless prepare succeeds. The class will throw exceptions on error and if this happens, the failed object instance should be discarded. Usage is in CompileExecutable (angelscript.cpp).
class nvgt_compilation_output {
public:
	virtual ~nvgt_compilation_output() {}
	virtual void prepare() = 0; // Copies the configured stub and opens the copy for writing the payload, allowing for any per-platform handling during the process such as extracting nvgt_android.bin (a zip file) then opening the contained libgame.so, just directly opening nvgt_windows.bin (an executable) for writing, or anything else in between so long as write_payload can then be safely called.
	virtual void write_payload(const unsigned char* payload, unsigned int size) = 0; // This also takes care of writing embedded packs.
	virtual void finalize() = 0; // Does anything necessary per platform to take the now prepared output executable or binary and bundle it into a package that is as ready to be run by an end player to the best extent NVGT can manage, usually driven by several configuration options. This might do anything from copying shared libraries to preparing an entire app bundle depending on platform and configuration.
	virtual void postbuild() = 0; // Only after the build is successful and that fact is reported to the user, this function is run so that the bundling system can perform any last steps before the bundle object is destroyed. This is a no-op on most platforms, however if nvgt can for example install an app after building it, such a thing should be done here. You can also perform any cleanup that you feel would be unsafe to do in the destructor.
	virtual const std::string& get_error_text() = 0;
	virtual const std::string& get_output_file() = 0;
};
nvgt_compilation_output* nvgt_init_compilation(const std::string& input_file, bool auto_prepare = true);
