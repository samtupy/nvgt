/* xplatform.h - header for various cross platform macros and routines
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

#include <string>
#include <Poco/Path.h>
#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

class asIScriptEngine;

bool running_on_mobile();
#ifndef NVGT_STUB
void determine_compile_platform();
void xplatform_correct_path_to_stubs(Poco::Path& stubpath);
std::string get_nvgt_lib_directory(const std::string& platform);
#endif
#if defined(__ANDROID__) || defined(__APPLE__) && TARGET_OS_IPHONE
#define NVGT_MOBILE
#endif
#if defined(__APPLE__) || defined(__ANDROID__)
std::string event_requested_file();
#endif
#ifdef __ANDROID__
std::string android_get_main_shared_object();
#endif

void RegisterXplatform(asIScriptEngine* engine);
