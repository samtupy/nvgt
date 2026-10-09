/* version.h - externs for automatically generated version information constants that exist in version.cpp at compile time
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

extern const std::string NVGT_VERSION; // major.minor.patch-type
extern const std::string NVGT_VERSION_COMMIT_HASH; // derived from `git rev-parse HEAD`
extern const std::string NVGT_VERSION_BUILD_TIME; // from python strftime specifiers "%A, %B %d, %Y at %I:%M:%S %p %Z"
extern unsigned int NVGT_VERSION_BUILD_TIMESTAMP; // Unix epoch in seconds
extern int NVGT_VERSION_MAJOR, NVGT_VERSION_MINOR, NVGT_VERSION_PATCH;
extern const std::string NVGT_VERSION_TYPE;
