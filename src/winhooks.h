/* winhooks.h - Windows API hooks for anti-cheat measures
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

/**
Applies windows API hooks to prevent script kitty cheating

This function, on windows, applies windows API hooks to prevent script kitty cheating attempts (i.e. speed hacks). It does not prevent actually advanced cheating attempts; that is not the purpose of this function.

On other platforms, this function is a no-op.

*** WARNING ***

After this function is  called, any of it's hooked routines cannot be called either by NVGT or (theoretically) by other processes on the system that call into NVGT. Do *NOT* call any hooked routines after this function has been called -- you will get ERROR_ACCESS_DENIED if you do!
*/
void apply_winapi_hooks();
