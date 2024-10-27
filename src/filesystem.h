/* filesystem.h - filesystem functions header
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
#include <angelscript.h>
#include <string>

bool FileCopy(const std::string& source, const std::string& target, bool overwrite);
bool FileMove(const std::string& source, const std::string& target);
bool FileExists(const std::string& path);
asINT64 FileGetSize(const std::string& path);
std::string file_get_contents(const std::string& filename);
void RegisterScriptFileSystemFunctions(asIScriptEngine* engine);
