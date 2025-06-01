/* combination_api.cpp - Add combination generators to AngelScript.
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

#include <angelscript.h>
#include <scriptarray.h>

#include "combination_api.h"

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
	if(!gen->advance()) return false;
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
	if (asAtomicDec(refcount) < 1) {
		delete this;
	}
}
combination_api *combination_factory() {
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
