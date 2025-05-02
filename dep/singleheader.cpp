/* singleheader.cpp
 * This file defines the implementations of all single header dependencies used in this project to increase build speed.
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

#ifdef _WIN32
#include <windows.h>
#else
#include <cstdio>
#include <cstdlib>
#include <cstring>
#endif
#ifdef __ANDROID__
#define ANDROID_FOPEN_IMPLEMENTATION
#include "android_fopen.h"
#endif

#define BL_NUMWORDS_IMPLEMENTATION
#include "bl_number_to_words.h"
#define DBGTOOLS_IMPLEMENTATION
#include "dbgtools.h"
#define RND_IMPLEMENTATION
#include "rnd.h"
#define SPEECH_IMPLEMENTATION
#include "speech.h"
#define THREAD_IMPLEMENTATION
#include "thread.h"
