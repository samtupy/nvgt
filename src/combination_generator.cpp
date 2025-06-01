/* combination_generator.cpp - Common implementations for combination_generator class.
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

#include "combination_generator.h"

combination_generator::combination_generator() {
	reset();
}
combination_generator::~combination_generator() {
	reset();
}
void combination_generator::reset() {
	current.clear();
	generating = false;
	items = 0;
	size = 0;
	min_size = 0;
	max_size = 0;
}
bool combination_generator::initialize(int items, int min_size, int max_size) {
	if (!validate(items, min_size, max_size)) return false;
	reset();
	this->items = items;
	this->min_size = min_size;
	this->max_size = max_size;
	size = min_size;
	generating = true;
	return true;
}
std::vector<int>& combination_generator::data() {
	return current;
}
bool combination_generator::active() {
	return generating;
}

bool combination_generator::validate(int items, int min_size, int max_size) {
	if(items < 2) return false;
	if (min_size < 1) return false;
	if (max_size < min_size) return false;
	return true;
}
