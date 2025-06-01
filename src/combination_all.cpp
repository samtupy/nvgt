/* combination_all.cpp - Algorithm for returning all combinations in a set.
 * Written by Day Garwood, 31st May 2025
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

#include "combination_all.h"

bool combination_all::advance() {
	if (!generating) return false;
	if (current.empty()) return build_first();
	if (increase_counter()) return true;
	if (next_size()) return true;
	reset();
	return false;
	}

bool combination_all::build_first() {
	current.resize(size);
	current.assign(size, 0);
	return true;
}
bool combination_all::increase_counter() {
	for (int pos = size - 1; pos >= 0; pos--) {
		current[pos]++;
		if (current[pos] < items) return true;
		current[pos]=0;
		if (pos == 0) return false;
	}
return false;
}
bool combination_all::next_size() {
	size++;
	if (size > max_size) return false;
	return build_first();
}
