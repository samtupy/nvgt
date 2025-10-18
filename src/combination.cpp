/* combination.cpp - Add combination generators to AngelScript.
 * Written by Day Garwood, 31st May - 1st June 2025
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

#include <algorithm>
#include <numeric>
#include <angelscript.h>
#include <scriptarray.h>
#include "combination.h"

// Common implementations for combination_generator class.
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
	if (items < 2) return false;
	if (min_size < 1) return false;
	if (max_size < min_size) return false;
	return true;
}

// Algorithm for returning all combinations in a set.
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
		current[pos] = 0;
		if (pos == 0) return false;
	}
	return false;
}
bool combination_all::next_size() {
	size++;
	if (size > max_size) return false;
	return build_first();
}

// Algorithm for returning all permutations in a set.
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

// Algorithm for returning unique combinations in a set.
bool combination_unique::validate(int items, int min_size, int max_size) {
	if (!combination_generator::validate(items, min_size, max_size)) return false;
	if (items < 3) return false;
	if (max_size >= items) return false;
	return true;
}
bool combination_unique::advance() {
	if (!generating) return false;
	if (current.empty()) return build_first();
	if (increase_counter()) return true;
	if (next_size()) return true;
	reset();
	return false;
}
bool combination_unique::build_first() {
	current.resize(size);
	std::iota(current.begin(), current.end(), 0);
	return true;
}
bool combination_unique::increase_counter() {
	int i = size - 1;
	while (i >= 0 && current[i] >= items - size + i)
		i--;
	if (i < 0) return false;
	current[i]++;
	for (int j = i + 1; j < size; ++j)
		current[j] = current[j - 1] + 1;
	return true;
}
bool combination_unique::next_size() {
	size++;
	if (size > max_size) return false;
	return build_first();
}

// API
combination_api::combination_api() {
	reset();
}
combination_api::~combination_api() {
	reset();
}
void combination_api::reset() {
	gen.reset();
}
bool combination_api::generate_all_combinations(int items, int size) {
	return generate_all_combinations(items, size, size);
}
bool combination_api::generate_all_combinations(int items, int min_size, int max_size) {
	auto gen = std::make_unique<combination_all>();
	if (!gen->initialize(items, min_size, max_size)) return false;
	this->gen = std::move(gen);
	return true;
}
bool combination_api::generate_unique_combinations(int items, int size) {
	return generate_unique_combinations(items, size, size);
}
bool combination_api::generate_unique_combinations(int items, int min_size, int max_size) {
	auto gen = std::make_unique<combination_unique>();
	if (!gen->initialize(items, min_size, max_size)) return false;
	this->gen = std::move(gen);
	return true;
}
bool combination_api::generate_permutations(int items) {
	auto gen = std::make_unique<combination_permutation>();
	if (!gen->initialize(items, 0, 0)) return false; // Size is ignored.
	this->gen = std::move(gen);
	return true;
}
bool combination_api::next(CScriptArray* list) {
	if (!list) return false;
	if (!is_active()) return false;
	if (!gen->advance()) return false;
	std::vector<int>& temp = gen->data();
	list->Resize(temp.size());
	for (int i = 0; i < temp.size(); i++)
		list->SetValue(i, &temp[i]);
	return true;
}
bool combination_api::is_active() {
	if (!gen) return false;
	return gen->active();
}
void combination_api::add_ref() {
	asAtomicInc(refcount);
}
void combination_api::release() {
	if (asAtomicDec(refcount) < 1)
		delete this;
}
combination_api* combination_factory() {
	return new combination_api();
}
void RegisterScriptCombination(asIScriptEngine* engine) {
	engine->RegisterObjectType("combination", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("combination", asBEHAVE_FACTORY, "combination@ f()", asFUNCTION(combination_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("combination", asBEHAVE_ADDREF, "void f()", asMETHOD(combination_api, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("combination", asBEHAVE_RELEASE, "void f()", asMETHOD(combination_api, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "void reset()", asMETHOD(combination_api, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool generate_all_combinations(int items, int size)", asMETHODPR(combination_api, generate_all_combinations, (int, int), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool generate_all_combinations(int items, int min_size, int max_size)", asMETHODPR(combination_api, generate_all_combinations, (int, int, int), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool generate_unique_combinations(int items, int size)", asMETHODPR(combination_api, generate_unique_combinations, (int, int), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool generate_unique_combinations(int items, int min_size, int max_size)", asMETHODPR(combination_api, generate_unique_combinations, (int, int, int), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool generate_permutations(int items)", asMETHOD(combination_api, generate_permutations), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool next(int[]@ list)", asMETHOD(combination_api, next), asCALL_THISCALL);
	engine->RegisterObjectMethod("combination", "bool get_active() property", asMETHOD(combination_api, is_active), asCALL_THISCALL);
}
