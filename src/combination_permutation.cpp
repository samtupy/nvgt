/* combination_permutation.cpp - Algorithm for returning all permutations in a set.
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

#include "combination_permutation.h"

bool combination_permutation::validate(int items, int min_size, int max_size) {
	// This generator ignores size.
	if (items < 1) return false;
	return true;
}
bool combination_permutation::advance() {
	if (!generating) return false;
	if (current.empty()) return build_first();
	if (std::next_permutation(current.begin(), current.end())) return true;
	reset();
	return false;
}
bool combination_permutation::build_first() {
	current.resize(items);
	std::iota(current.begin(), current.end(), 0);
	return true;
}
