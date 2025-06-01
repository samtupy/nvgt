/* combination_api.h - Header for combination_api interface.
 * Written by Day Garwood, 1st June 2025
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

#include "combination_all.h"
#include "combination_unique.h"
#include "combination_permutation.h"

#include <memory>

class CScriptArray;
class asIScriptEngine;

class combination_api {
public:
	combination_api();
	~combination_api();
	void reset();
	bool generate_all_combinations(int items, int size);
	bool generate_all_combinations(int items, int min_size, int max_size);
	bool generate_unique_combinations(int items, int size);
	bool generate_unique_combinations(int items, int min_size, int max_size);
	bool generate_permutations(int items);
	bool next(CScriptArray* list);
	bool is_active();

	// AS stuff
	void add_ref();
	void release();

private:
	std::unique_ptr<combination_generator> gen;
	int refcount = 1;
};

combination_api *combination_factory();
void RegisterScriptCombination(asIScriptEngine* engine);
