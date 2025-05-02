/* misc_functions.h - header for miscellaneous wrapped functions that have no better place
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
#include <angelscript.h>
#include "nvgt.h"

asINT64 GetFileSize(const std::string& path);
BOOL ChDir(const std::string& d);
double range_convert(double old_value, double old_min, double old_max, double new_min, double new_max);
float parse_float(const std::string& val);
double parse_double(const std::string& val);
bool is_valid_utf8(const std::string &text, bool ban_ascii_special = true);
class refstring {
public:
	int RefCount;
	std::string str;
	refstring() : RefCount(1) {}
	void AddRef() {
		asAtomicInc(RefCount);
	}
	void Release() {
		if (asAtomicDec(RefCount) < 1) delete this;
	}
};
void RegisterMiscFunctions(asIScriptEngine* engine);
