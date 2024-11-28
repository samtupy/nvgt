/* random.cpp - random number generators
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

#include <rnd.h>
#include <math.h>
#include <obfuscate.h>
#include <array>
#include <cstring>
#include <string>
#include <sstream>
#include <vector>
#include <rng_get_bytes.h>
#include <aswrappedcall.h>
#include <Poco/Base64Decoder.h>
#include <Poco/Base64Encoder.h>
#include <scriptarray.h>
#include "nvgt.h"
#include "random.h"

static rnd_pcg_t rng;
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
	if (state == "") {
		rnd_pcg_seed(&rng, random_seed());
		return true;
	}
	std::vector<unsigned char> r;
	std::istringstream istr(state);
	Poco::Base64Decoder dec(istr);
	char c;
	while (dec.get(c))
		r.push_back(c);
	if (r.size() != sizeof(rng.state))
		return false;
	memcpy(&rng.state[0], &r[0], sizeof(rng.state));
	return true;
}
std::string random_get_state() {
	std::ostringstream ostr;
	Poco::Base64Encoder enc(ostr);
	enc << std::string((char*)rng.state, sizeof(rng.state));
	enc.close();
	return ostr.str();
}
int random(int min, int max) {
	return rnd_pcg_range(&rng, min, max);
}
float random_float() {
	return rnd_pcg_nextf(&rng);
}
bool random_bool(int percent) {
	if (percent < 1) return false;
	if (percent >= 100) return true;
	return random(0, 99) < percent;
}
std::string random_character(const std::string& min, std::string& max) {
	if (min == "" || max == "") return "";
	if (min == max) return min;
	return std::string(1, (char)random(min[0], max[0]));
}
void* random_choice(CScriptArray* array) {
	return array->At(random(0, array->GetSize() -1));
}
void rnd_pcg_construct(rnd_pcg_t* r) {
	rnd_pcg_seed(r, random_seed());
}
void* rnd_pcg_choice(CScriptArray* array, rnd_pcg_t* r) {
	return array->At(rnd_pcg_range(r, 0, array->GetSize() -1));
}
void rnd_well_construct(rnd_well_t* r) {
	rnd_well_seed(r, random_seed());
}
void* rnd_well_choice(CScriptArray* array, rnd_well_t* r) {
	return array->At(rnd_well_range(r, 0, array->GetSize() -1));
}
void rnd_gamerand_construct(rnd_gamerand_t* r) {
	rnd_gamerand_seed(r, random_seed());
}
void* rnd_gamerand_choice(CScriptArray* array, rnd_gamerand_t* r) {
	return array->At(rnd_gamerand_range(r, 0, array->GetSize() -1));
}
void rnd_xorshift_construct(rnd_xorshift_t* r) {
	rnd_xorshift_seed(r, random_seed64());
}
void* rnd_xorshift_choice(CScriptArray* array, rnd_xorshift_t* r) {
	return array->At(rnd_xorshift_range(r, 0, array->GetSize() -1));
}

void RegisterScriptRandom(asIScriptEngine* engine) {
	rnd_pcg_seed(&rng, random_seed());
	engine->RegisterGlobalFunction(_O("bool random_set_state(const string& in)"), asFUNCTION(random_set_state), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string random_get_state()"), asFUNCTION(random_get_state), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint random_seed()"), asFUNCTION(random_seed), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 random_seed64()"), asFUNCTION(random_seed64), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int random(int, int)"), WRAP_FN_PR(random, (int, int), int), asCALL_GENERIC);
	engine->RegisterGlobalFunction(_O("float random_float()"), asFUNCTION(random_float), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool random_bool(int = 50)"), asFUNCTION(random_bool), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string random_character(const string& in, const string& in)"), asFUNCTION(random_character), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random() const"), asFUNCTION(random_choice), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType(_O("random_pcg"), sizeof(rnd_pcg_t), asOBJ_VALUE | asOBJ_POD);
	engine->RegisterObjectBehaviour(_O("random_pcg"), asBEHAVE_CONSTRUCT, _O("void f()"), WRAP_OBJ_FIRST(rnd_pcg_construct), asCALL_GENERIC);
	engine->RegisterObjectBehaviour(_O("random_pcg"), asBEHAVE_CONSTRUCT, _O("void f(uint)"), WRAP_OBJ_FIRST(rnd_pcg_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("void seed(uint = random_seed())"), WRAP_OBJ_FIRST(rnd_pcg_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("uint next()"), WRAP_OBJ_FIRST(rnd_pcg_next), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("float nextf()"), WRAP_OBJ_FIRST(rnd_pcg_nextf), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_pcg"), _O("int range(int, int)"), WRAP_OBJ_FIRST(rnd_pcg_range), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_pcg&in generator) const"), WRAP_OBJ_FIRST(rnd_pcg_choice), asCALL_GENERIC);
	engine->RegisterObjectType(_O("random_well"), sizeof(rnd_well_t), asOBJ_VALUE | asOBJ_POD);
	engine->RegisterObjectBehaviour(_O("random_well"), asBEHAVE_CONSTRUCT, _O("void f()"), WRAP_OBJ_FIRST(rnd_well_construct), asCALL_GENERIC);
	engine->RegisterObjectBehaviour(_O("random_well"), asBEHAVE_CONSTRUCT, _O("void f(uint = random_seed())"), WRAP_OBJ_FIRST(rnd_well_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_well"), _O("void seed(uint = random_seed())"), WRAP_OBJ_FIRST(rnd_well_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_well"), _O("uint next()"), WRAP_OBJ_FIRST(rnd_well_next), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_well"), _O("float nextf()"), WRAP_OBJ_FIRST(rnd_well_nextf), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_well"), _O("int range(int, int)"), WRAP_OBJ_FIRST(rnd_well_range), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_well&in generator) const"), WRAP_OBJ_FIRST(rnd_well_choice), asCALL_GENERIC);
	engine->RegisterObjectType(_O("random_gamerand"), sizeof(rnd_gamerand_t), asOBJ_VALUE | asOBJ_POD);
	engine->RegisterObjectBehaviour(_O("random_gamerand"), asBEHAVE_CONSTRUCT, _O("void f()"), WRAP_OBJ_FIRST(rnd_gamerand_construct), asCALL_GENERIC);
	engine->RegisterObjectBehaviour(_O("random_gamerand"), asBEHAVE_CONSTRUCT, _O("void f(uint = random_seed())"), WRAP_OBJ_FIRST(rnd_gamerand_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("void seed(uint = random_seed())"), WRAP_OBJ_FIRST(rnd_gamerand_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("uint next()"), WRAP_OBJ_FIRST(rnd_gamerand_next), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("float nextf()"), WRAP_OBJ_FIRST(rnd_gamerand_nextf), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_gamerand"), _O("int range(int, int)"), WRAP_OBJ_FIRST(rnd_gamerand_range), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_gamerand&in generator) const"), WRAP_OBJ_FIRST(rnd_gamerand_choice), asCALL_GENERIC);
	engine->RegisterObjectType(_O("random_xorshift"), sizeof(rnd_xorshift_t), asOBJ_VALUE | asOBJ_POD);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_CONSTRUCT, _O("void f()"), WRAP_OBJ_FIRST(rnd_xorshift_construct), asCALL_GENERIC);
	engine->RegisterObjectBehaviour(_O("random_xorshift"), asBEHAVE_CONSTRUCT, _O("void f(uint64 = random_seed64())"), WRAP_OBJ_FIRST(rnd_xorshift_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("void seed(uint64 = random_seed64())"), WRAP_OBJ_FIRST(rnd_xorshift_seed), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("uint64 next()"), WRAP_OBJ_FIRST(rnd_xorshift_next), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("float nextf()"), WRAP_OBJ_FIRST(rnd_xorshift_nextf), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("random_xorshift"), _O("int range(int, int)"), WRAP_OBJ_FIRST(rnd_xorshift_range), asCALL_GENERIC);
	engine->RegisterObjectMethod(_O("array<T>"), _O("const T& random(const random_xorshift&in generator) const"), WRAP_OBJ_FIRST(rnd_xorshift_choice), asCALL_GENERIC);
}
