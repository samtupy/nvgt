/* combination_generator.h - Abstract class for plugging in various combinatorics algorithms.
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

#pragma once

#include <vector>

class combination_generator {
public:
	combination_generator();
	virtual ~combination_generator();
	virtual void reset();
	virtual bool initialize(int items, int min_size, int max_size);
	virtual bool validate(int items, int min_size, int max_size);
	virtual bool advance() = 0;
	std::vector<int>& data();
	bool active();

protected:
	std::vector<int> current;
	bool generating;
	int items;
	int min_size;
	int max_size;
	int size;
};
