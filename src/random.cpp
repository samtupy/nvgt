/* random.cpp - random number generators
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

#include "random.h"

#include <Poco/Base64Decoder.h>
#include <Poco/Base64Encoder.h>
#include <aswrappedcall.h>
#include <math.h>
#include <obfuscate.h>
#include <rnd.h>
#include <rng_get_bytes.h>
#include <scriptarray.h>

#include <array>
#include <cstring>
#include <sstream>
#include <string>
#include <vector>

#include "nvgt.h"
#include "random_interface.h"

unsigned int random_seed() {
	unsigned int seed;
	rng_get_bytes((unsigned char*)&seed, sizeof(unsigned int));
	return seed;
}
asQWORD random_seed64() {
	asQWORD seed;
	rng_get_bytes((unsigned char*)&seed, sizeof(asQWORD));
	return seed;
}

bool random_set_state(const std::string& state) {
	return get_default_random()->set_state(state);
}
std::string random_get_state() {
	return get_default_random()->get_state();
}
int random(int min, int max) {
	return get_default_random()->range(min, max);
}
int64 random64(int64 min, int64 max) {
	return g_random_xorshift->range64(min, max);
}

float random_float() {
	return get_default_random()->nextf();
}
bool random_bool(int percent) {
	if (percent < 1) return false;
	if (percent >= 100) return true;
	return get_default_random()->next_bool(percent);
}
std::string random_character(const std::string& min, std::string& max) {
	if (min == "" || max == "") return "";
	if (min == max) return min;
	return std::string(1, (char)random(min[0], max[0]));
}
void* random_choice(CScriptArray* array) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	return array->At(get_default_random()->range(0, array->GetSize() - 1));
}

// Wrapper function for AngelScript registration
static void random_choice_wrapper(asIScriptGeneric* gen) {
	CScriptArray* array = (CScriptArray*)gen->GetObject();
	void* result = random_choice(array);
	if (result)
		gen->SetReturnAddress(result);
	else
		gen->SetReturnAddress(nullptr);
}
void random_shuffle(CScriptArray* array) {
	if (array->GetSize() < 2) return;
	// Angelscript doesn't make it easy to copy and manipulate objects from the c++ side, For example it's own array implementation's SetValue method is like 63 lines of code and it does not have a swap method. We instead opt to resize the array to size+1 and use the temporary slot for swapping before removing it after the shuffle.
	array->Resize(array->GetSize() + 1);
	for (asUINT i = array->GetSize() - 2; i > 0; i--) {
		int j = random(0, i);
		array->SetValue(array->GetSize() - 1, array->At(i));
		array->SetValue(i, array->At(j));
		array->SetValue(j, array->At(array->GetSize() - 1));
	}
	array->Resize(array->GetSize() - 1);
}
void rnd_pcg_construct(rnd_pcg_t* r) {
	rnd_pcg_seed(r, random_seed());
}
void* rnd_pcg_choice(CScriptArray* array, rnd_pcg_t* r) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	return array->At(rnd_pcg_range(r, 0, array->GetSize() - 1));
}
void rnd_well_construct(rnd_well_t* r) {
	rnd_well_seed(r, random_seed());
}
void* rnd_well_choice(CScriptArray* array, rnd_well_t* r) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	return array->At(rnd_well_range(r, 0, array->GetSize() - 1));
}
void rnd_gamerand_construct(rnd_gamerand_t* r) {
	rnd_gamerand_seed(r, random_seed());
}
void* rnd_gamerand_choice(CScriptArray* array, rnd_gamerand_t* r) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	return array->At(rnd_gamerand_range(r, 0, array->GetSize() - 1));
}
void rnd_xorshift_construct(rnd_xorshift_t* r) {
	rnd_xorshift_seed(r, random_seed64());
}
void* rnd_xorshift_choice(CScriptArray* array, rnd_xorshift_t* r) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	return array->At(rnd_xorshift_range(r, 0, array->GetSize() - 1));
}

// Cast function for random generators to the base interface
template <typename T>
random_interface* random_cast_to(T* obj) {
	if (!obj) return nullptr;
	obj->add_ref();
	return static_cast<random_interface*>(obj);
}

void RegisterScriptRandom(asIScriptEngine* engine) {
	// Initialize the default random interface with a random_pcg instance
	random_pcg* default_rng = new random_pcg();
	init_default_random(default_rng);
	default_rng->release(); // init_default_random already added a ref
	g_random_xorshift = new random_xorshift();
	// Register legacy global functions for backwards compatibility
	engine->RegisterGlobalFunction(_O("bool random_set_state(const string& in)"), asFUNCTION(random_set_state), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string random_get_state()"), asFUNCTION(random_get_state), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint random_seed()"), asFUNCTION(random_seed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 random_seed64()"), asFUNCTION(random_seed64), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int random(int, int)"), WRAP_FN_PR(random, (int, int), int), asCALL_GENERIC);
	engine->RegisterGlobalFunction(_O("int64 random64(int64, int64)"), asFUNCTION(random64), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("float random_float()"), asFUNCTION(random_float), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool random_bool(int = 50)"), asFUNCTION(random_bool), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string random_character(const string& in, const string& in)"), asFUNCTION(random_character), asCALL_CDECL);
	// Register the base random_interface as both a concrete type (for C++ objects) and an interface (for script inheritance)
	engine->RegisterObjectType(_O("random_interface"), 0, asOBJ_REF | asOBJ_NOCOUNT);
	engine->RegisterObjectMethod(_O("random_interface"), _O("uint next()"), asMETHOD(random_interface, next), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("float nextf()"), asMETHOD(random_interface, nextf), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("int range(int min, int max)"), asMETHOD(random_interface, range), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("void seed(uint s)"), asMETHOD(random_interface, seed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("void seed64(uint64 s)"), asMETHOD(random_interface, seed64), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("string get_state() const"), asMETHOD(random_interface, get_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("bool set_state(const string &in state)"), asMETHOD(random_interface, set_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("bool next_bool(int percent = 50)"), asMETHOD(random_interface, next_bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_interface"), _O("string next_character(const string &in min, const string &in max)"), asMETHOD(random_interface, next_character), asCALL_THISCALL);
	// Also register as a pure interface that scripts can implement
	engine->RegisterInterface(_O("random_generator"));
	engine->RegisterInterfaceMethod(_O("random_generator"), _O("uint next()"));
	engine->RegisterInterfaceMethod(_O("random_generator"), _O("float nextf()"));
	engine->RegisterInterfaceMethod(_O("random_generator"), _O("int range(int min, int max)"));
	engine->RegisterInterfaceMethod(_O("random_generator"), _O("bool next_bool(int percent = 50)"));
	engine->RegisterInterfaceMethod(_O("random_generator"), _O("string next_character(const string &in min, const string &in max)"));
	engine->RegisterGlobalFunction(_O("random_interface@ get_default_random()"), asFUNCTION(get_default_random), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void set_default_random(random_interface@)"), asFUNCTION(set_default_random), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void set_default_random(random_generator@)"), asFUNCTION(set_default_random_script), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random() const"), WRAP_OBJ_FIRST(random_choice), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(random_interface@ rng) const"), WRAP_OBJ_FIRST(random_array_choice), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(random_generator@ rng) const"), WRAP_OBJ_FIRST(random_script_array_choice), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle()"), asFUNCTION(random_shuffle), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle(random_interface@ rng)"), asFUNCTION(random_array_shuffle), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle(random_generator@ rng)"), asFUNCTION(random_script_array_shuffle), asCALL_CDECL_OBJFIRST);
	// Register new random generator classes with interface inheritance
	// PCG generator
	engine->RegisterObjectType(_O("random_pcg"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("random_pcg"), asBEHAVE_FACTORY, _O("random_pcg@ f()"), asFUNCTION(random_pcg_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_pcg"), asBEHAVE_FACTORY, _O("random_pcg@ f(uint seed)"), asFUNCTION(random_pcg_factory_seed), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_pcg"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(random_pcg, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("random_pcg"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(random_pcg, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("uint next()"), asMETHOD(random_pcg, next), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("float nextf()"), asMETHOD(random_pcg, nextf), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("int range(int min, int max)"), asMETHOD(random_pcg, range), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("void seed(uint s)"), asMETHOD(random_pcg, seed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("string get_state() const"), asMETHOD(random_pcg, get_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("bool set_state(const string &in state)"), asMETHOD(random_pcg, set_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("bool next_bool(int percent = 50)"), asMETHOD(random_pcg, next_bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("string next_character(const string &in min, const string &in max)"), asMETHOD(random_pcg, next_character), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("random_interface@ opImplCast()"), asFUNCTION(random_cast_to<random_pcg>), asCALL_CDECL_OBJFIRST);
	// WELL generator
	engine->RegisterObjectType(_O("random_well"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("random_well"), asBEHAVE_FACTORY, _O("random_well@ f()"), asFUNCTION(random_well_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_well"), asBEHAVE_FACTORY, _O("random_well@ f(uint seed)"), asFUNCTION(random_well_factory_seed), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_well"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(random_well, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("random_well"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(random_well, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("uint next()"), asMETHOD(random_well, next), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("float nextf()"), asMETHOD(random_well, nextf), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("int range(int min, int max)"), asMETHOD(random_well, range), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("void seed(uint s)"), asMETHOD(random_well, seed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("string get_state() const"), asMETHOD(random_well, get_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("bool set_state(const string &in state)"), asMETHOD(random_well, set_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("bool next_bool(int percent = 50)"), asMETHOD(random_well, next_bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("string next_character(const string &in min, const string &in max)"), asMETHOD(random_well, next_character), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_well"), _O("random_interface@ opImplCast()"), asFUNCTION(random_cast_to<random_well>), asCALL_CDECL_OBJFIRST);
	// Gamerand generator
	engine->RegisterObjectType(_O("random_gamerand"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("random_gamerand"), asBEHAVE_FACTORY, _O("random_gamerand@ f()"), asFUNCTION(random_gamerand_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_gamerand"), asBEHAVE_FACTORY, _O("random_gamerand@ f(uint seed)"), asFUNCTION(random_gamerand_factory_seed), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_gamerand"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(random_gamerand, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("random_gamerand"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(random_gamerand, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("uint next()"), asMETHOD(random_gamerand, next), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("float nextf()"), asMETHOD(random_gamerand, nextf), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("int range(int min, int max)"), asMETHOD(random_gamerand, range), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("void seed(uint s)"), asMETHOD(random_gamerand, seed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("string get_state() const"), asMETHOD(random_gamerand, get_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("bool set_state(const string &in state)"), asMETHOD(random_gamerand, set_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("bool next_bool(int percent = 50)"), asMETHOD(random_gamerand, next_bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("string next_character(const string &in min, const string &in max)"), asMETHOD(random_gamerand, next_character), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("random_interface@ opImplCast()"), asFUNCTION(random_cast_to<random_gamerand>), asCALL_CDECL_OBJFIRST);
	// Xorshift generator
	engine->RegisterObjectType(_O("random_xorshift"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_FACTORY, _O("random_xorshift@ f()"), asFUNCTION(random_xorshift_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_FACTORY, _O("random_xorshift@ f(uint seed)"), asFUNCTION(random_xorshift_factory_seed_uint), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_FACTORY, _O("random_xorshift@ f(uint64 seed)"), asFUNCTION(random_xorshift_factory_seed), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(random_xorshift, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(random_xorshift, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("uint next()"), asMETHOD(random_xorshift, next), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("float nextf()"), asMETHOD(random_xorshift, nextf), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("int64 next64()"), asMETHOD(random_xorshift, next64), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("int range(int min, int max)"), asMETHOD(random_xorshift, range), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("void seed(uint s)"), asMETHOD(random_xorshift, seed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("void seed64(uint64 s)"), asMETHOD(random_xorshift, seed64), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("string get_state() const"), asMETHOD(random_xorshift, get_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("bool set_state(const string &in state)"), asMETHOD(random_xorshift, set_state), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("bool next_bool(int percent = 50)"), asMETHOD(random_xorshift, next_bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("string next_character(const string &in min, const string &in max)"), asMETHOD(random_xorshift, next_character), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("random_interface@ opImplCast()"), asFUNCTION(random_cast_to<random_xorshift>), asCALL_CDECL_OBJFIRST);
	// Register new array methods for the specific generator types
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(random_pcg@ generator) const"), asFUNCTION(random_array_choice_wrapper), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(random_well@ generator) const"), asFUNCTION(random_array_choice_wrapper), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(random_gamerand@ generator) const"), asFUNCTION(random_array_choice_wrapper), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(random_xorshift@ generator) const"), asFUNCTION(random_array_choice_wrapper), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle(random_pcg@ generator)"), asFUNCTION(random_array_shuffle), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle(random_well@ generator)"), asFUNCTION(random_array_shuffle), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle(random_gamerand@ generator)"), asFUNCTION(random_array_shuffle), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("array<T>"), _O("void shuffle(random_xorshift@ generator)"), asFUNCTION(random_array_shuffle), asCALL_CDECL_OBJFIRST);
	// Keep old array methods for backward compatibility with existing generators
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_pcg&in generator) const"), WRAP_OBJ_FIRST(rnd_pcg_choice), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_well&in generator) const"), WRAP_OBJ_FIRST(rnd_well_choice), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_gamerand&in generator) const"), WRAP_OBJ_FIRST(rnd_gamerand_choice), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_xorshift&in generator) const"), WRAP_OBJ_FIRST(rnd_xorshift_choice), asCALL_GENERIC);
}
