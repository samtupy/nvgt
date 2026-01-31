/* random_interface.cpp - object-oriented random number generator implementation
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

#include "random_interface.h"

#include <Poco/Base64Decoder.h>
#include <Poco/Base64Encoder.h>
#include <angelscript.h>
#include <rng_get_bytes.h>
#include <scriptarray.h>

#include <cstring>
#include <sstream>
#include <vector>

#include "random.h"

// Wrapper class to make script objects compatible with random_interface
class script_random_wrapper : public random_interface {
private:
	asIScriptObject* scriptObj;
	asIScriptContext* ctx;
	asIScriptFunction* nextFunc;
	asIScriptFunction* next64Func;
	asIScriptFunction* nextfFunc;
	asIScriptFunction* rangeFunc;
	asIScriptFunction* range64Func;
	asIScriptFunction* nextBoolFunc;
	asIScriptFunction* nextCharFunc;
	int32 ref_count;

public:
	script_random_wrapper(asIScriptObject* obj) : scriptObj(obj), ref_count(1) {
		if (scriptObj) {
			scriptObj->AddRef();
			asIScriptEngine* engine = scriptObj->GetEngine();
			ctx = engine->CreateContext();
			// Get method pointers
			nextFunc = scriptObj->GetObjectType()->GetMethodByDecl("uint next()");
			next64Func = scriptObj->GetObjectType()->GetMethodByDecl("int64 next64()");
			nextfFunc = scriptObj->GetObjectType()->GetMethodByDecl("float nextf()");
			rangeFunc = scriptObj->GetObjectType()->GetMethodByDecl("int range(int, int)");
			range64Func = scriptObj->GetObjectType()->GetMethodByDecl("int64 range64(int64, int64)");
			nextBoolFunc = scriptObj->GetObjectType()->GetMethodByDecl("bool next_bool(int)");
			nextCharFunc = scriptObj->GetObjectType()->GetMethodByDecl("string next_character(const string&in, const string&in)");
		}
	}

	~script_random_wrapper() {
		if (scriptObj)
			scriptObj->Release();
		if (ctx)
			ctx->Release();
	}

	uint32 next() override {
		if (!nextFunc || !ctx) return 0;
		ctx->Prepare(nextFunc);
		ctx->SetObject(scriptObj);
		ctx->Execute();
		return ctx->GetReturnDWord();
	}

	float32 nextf() override {
		if (!nextfFunc || !ctx) return 0.0f;
		ctx->Prepare(nextfFunc);
		ctx->SetObject(scriptObj);
		ctx->Execute();
		return ctx->GetReturnFloat();
	}

		int64 next64() override {
		if (!next64Func || !ctx) return 0;
		ctx->Prepare(next64Func);
		ctx->SetObject(scriptObj);
		ctx->Execute();
		return ctx->GetReturnDWord();
	}

	int32 range(int32 min, int32 max) override {
		if (!rangeFunc || !ctx) return min;
		ctx->Prepare(rangeFunc);
		ctx->SetObject(scriptObj);
		ctx->SetArgDWord(0, min);
		ctx->SetArgDWord(1, max);
		ctx->Execute();
		return ctx->GetReturnDWord();
	}

		int64 range64(int64 min, int64 max) override {
		if (!range64Func || !ctx) return min;
		ctx->Prepare(range64Func);
		ctx->SetObject(scriptObj);
		ctx->SetArgDWord(0, min);
		ctx->SetArgDWord(1, max);
		ctx->Execute();
		return ctx->GetReturnDWord();
	}

	void seed(uint32 s) override {
		// Script objects handle their own seeding
	}

	void seed64(uint64 s) override {
		// Script objects handle their own seeding
	}

	std::string get_state() const override {
		return "";  // Script objects handle their own state
	}

	bool set_state(const std::string& state) override {
		return false;  // Script objects handle their own state
	}

	void add_ref() override {
		++ref_count;
	}

	void release() override {
		if (--ref_count == 0)
			delete this;
	}
};

// Global default random generator
random_interface* g_default_random = nullptr;
static script_random_wrapper* g_default_script_wrapper = nullptr;
random_xorshift* g_random_xorshift = nullptr;

// Initialize default generator with provided rng
void init_default_random(random_interface* rng) {
	if (rng) {
		g_default_random = rng;
		rng->add_ref();
	}
}

// Initialize default generator
static void ensure_default_random() {
	// Default should always be initialized from RegisterScriptRandom
	if (!g_default_random) {
		// This should never happen in normal operation
		g_default_random = new random_pcg();
	}
}

// Cleanup function to be called before engine shutdown
void cleanup_default_random() {
	// Be careful not to double-release
	if (g_default_random && g_default_random != g_default_script_wrapper)
		g_default_random->release();
	if (g_default_script_wrapper) {
		g_default_script_wrapper->release();
		g_default_script_wrapper = nullptr;
	}
	if (g_random_xorshift) {
		g_random_xorshift->release();
		g_random_xorshift = nullptr;
	}
	g_default_random = nullptr;
}

void set_default_random(random_interface* rng) {
	if (rng)
		rng->add_ref();
	if (g_default_random && g_default_random != g_default_script_wrapper)
		g_default_random->release();
	if (g_default_script_wrapper && g_default_random == g_default_script_wrapper) {
		g_default_script_wrapper = nullptr;  // Will be released above
	}
	g_default_random = rng;
}

void set_default_random_script(asIScriptObject* scriptObj) {
	if (!scriptObj) return;
	// Clean up previous default
	if (g_default_random && g_default_random != g_default_script_wrapper)
		g_default_random->release();
	if (g_default_script_wrapper)
		g_default_script_wrapper->release();
	// Create wrapper and set as default
	g_default_script_wrapper = new script_random_wrapper(scriptObj);
	g_default_random = g_default_script_wrapper;
}

random_interface* get_default_random() {
	ensure_default_random();
	return g_default_random;
}

// Base interface utility functions
bool random_interface::next_bool(int32 percent) {
	if (percent < 1) return false;
	if (percent >= 100) return true;
	return range(0, 99) < percent;
}

std::string random_interface::next_character(const std::string& min, const std::string& max) {
	if (min.empty() || max.empty()) return "";
	if (min == max) return min;
	return std::string(1, static_cast<char>(range(min[0], max[0])));
}

// PCG implementation
random_pcg::random_pcg() : ref_count(1) {
	seed(random_seed());
}

random_pcg::random_pcg(uint32 s) : ref_count(1) {
	seed(s);
}

uint32 random_pcg::next() {
	return rnd_pcg_next(&gen);
}

float32 random_pcg::nextf() {
	return rnd_pcg_nextf(&gen);
}

int32 random_pcg::range(int32 min, int32 max) {
	return rnd_pcg_range(&gen, min, max);
}

void random_pcg::seed(uint32 s) {
	rnd_pcg_seed(&gen, s);
}

std::string random_pcg::get_state() const {
	std::ostringstream ostr;
	Poco::Base64Encoder enc(ostr);
	enc << std::string(reinterpret_cast<const char*>(gen.state), sizeof(gen.state));
	enc.close();
	return ostr.str();
}

bool random_pcg::set_state(const std::string& state) {
	if (state.empty()) {
		seed(random_seed());
		return true;
	}
	std::vector<uint8> r;
	std::istringstream istr(state);
	Poco::Base64Decoder dec(istr);
	char c;
	while (dec.get(c))
		r.push_back(static_cast<uint8>(c));
	if (r.size() != sizeof(gen.state))
		return false;
	memcpy(&gen.state[0], &r[0], sizeof(gen.state));
	return true;
}

void random_pcg::add_ref() {
	++ref_count;
}

void random_pcg::release() {
	if (--ref_count == 0)
		delete this;
}

// WELL implementation
random_well::random_well() : ref_count(1) {
	seed(random_seed());
}

random_well::random_well(uint32 s) : ref_count(1) {
	seed(s);
}

uint32 random_well::next() {
	return rnd_well_next(&gen);
}

float32 random_well::nextf() {
	return rnd_well_nextf(&gen);
}

int32 random_well::range(int32 min, int32 max) {
	return rnd_well_range(&gen, min, max);
}

void random_well::seed(uint32 s) {
	rnd_well_seed(&gen, s);
}

std::string random_well::get_state() const {
	std::ostringstream ostr;
	Poco::Base64Encoder enc(ostr);
	enc << std::string(reinterpret_cast<const char*>(&gen), sizeof(gen));
	enc.close();
	return ostr.str();
}

bool random_well::set_state(const std::string& state) {
	if (state.empty()) {
		seed(random_seed());
		return true;
	}
	std::vector<uint8> r;
	std::istringstream istr(state);
	Poco::Base64Decoder dec(istr);
	char c;
	while (dec.get(c))
		r.push_back(static_cast<uint8>(c));
	if (r.size() != sizeof(gen))
		return false;
	memcpy(&gen, &r[0], sizeof(gen));
	return true;
}

void random_well::add_ref() {
	++ref_count;
}

void random_well::release() {
	if (--ref_count == 0)
		delete this;
}

// Gamerand implementation
random_gamerand::random_gamerand() : ref_count(1) {
	seed(random_seed());
}

random_gamerand::random_gamerand(uint32 s) : ref_count(1) {
	seed(s);
}

uint32 random_gamerand::next() {
	return rnd_gamerand_next(&gen);
}

float32 random_gamerand::nextf() {
	return rnd_gamerand_nextf(&gen);
}

int32 random_gamerand::range(int32 min, int32 max) {
	return rnd_gamerand_range(&gen, min, max);
}

void random_gamerand::seed(uint32 s) {
	rnd_gamerand_seed(&gen, s);
}

std::string random_gamerand::get_state() const {
	std::ostringstream ostr;
	Poco::Base64Encoder enc(ostr);
	enc << std::string(reinterpret_cast<const char*>(&gen), sizeof(gen));
	enc.close();
	return ostr.str();
}

bool random_gamerand::set_state(const std::string& state) {
	if (state.empty()) {
		seed(random_seed());
		return true;
	}
	std::vector<uint8> r;
	std::istringstream istr(state);
	Poco::Base64Decoder dec(istr);
	char c;
	while (dec.get(c))
		r.push_back(static_cast<uint8>(c));
	if (r.size() != sizeof(gen))
		return false;
	memcpy(&gen, &r[0], sizeof(gen));
	return true;
}

void random_gamerand::add_ref() {
	++ref_count;
}

void random_gamerand::release() {
	if (--ref_count == 0)
		delete this;
}

// Xorshift implementation
random_xorshift::random_xorshift() : ref_count(1) {
	uint64_t s;
	rng_get_bytes(reinterpret_cast<unsigned char*>(&s), sizeof(s));
	seed64(s);
}

random_xorshift::random_xorshift(uint64 s) : ref_count(1) {
	seed64(s);
}

uint32 random_xorshift::next() {
	return static_cast<uint32>(rnd_xorshift_next(&gen));
}

int64 random_xorshift::next64() {
	return static_cast<int64>(rnd_xorshift_next(&gen));
}

float32 random_xorshift::nextf() {
	return rnd_xorshift_nextf(&gen);
}

int32 random_xorshift::range(int32 min, int32 max) {
	return rnd_xorshift_range(&gen, min, max);
}

int64 random_xorshift::range64(int64 min, int64 max) {
	return rnd_xorshift_range64(&gen, min, max);
}

void random_xorshift::seed(uint32 s) {
	seed64(static_cast<uint64>(s));
}

void random_xorshift::seed64(uint64 s) {
	rnd_xorshift_seed(&gen, s);
}

std::string random_xorshift::get_state() const {
	std::ostringstream ostr;
	Poco::Base64Encoder enc(ostr);
	enc << std::string(reinterpret_cast<const char*>(&gen), sizeof(gen));
	enc.close();
	return ostr.str();
}

bool random_xorshift::set_state(const std::string& state) {
	if (state.empty()) {
		uint64_t s;
		rng_get_bytes(reinterpret_cast<unsigned char*>(&s), sizeof(s));
		seed64(s);
		return true;
	}
	std::vector<uint8> r;
	std::istringstream istr(state);
	Poco::Base64Decoder dec(istr);
	char c;
	while (dec.get(c))
		r.push_back(static_cast<uint8>(c));
	if (r.size() != sizeof(gen))
		return false;
	memcpy(&gen, &r[0], sizeof(gen));
	return true;
}

void random_xorshift::add_ref() {
	++ref_count;
}

void random_xorshift::release() {
	if (--ref_count == 0)
		delete this;
}

random_pcg* random_pcg_factory() {
	return new random_pcg();
}

random_pcg* random_pcg_factory_seed(uint32 seed) {
	return new random_pcg(seed);
}

random_well* random_well_factory() {
	return new random_well();
}

random_well* random_well_factory_seed(uint32 seed) {
	return new random_well(seed);
}

random_gamerand* random_gamerand_factory() {
	return new random_gamerand();
}

random_gamerand* random_gamerand_factory_seed(uint32 seed) {
	return new random_gamerand(seed);
}

random_xorshift* random_xorshift_factory() {
	return new random_xorshift();
}

random_xorshift* random_xorshift_factory_seed_uint(uint32 seed) {
	return new random_xorshift(static_cast<uint64>(seed));
}

random_xorshift* random_xorshift_factory_seed(uint64 seed) {
	return new random_xorshift(seed);
}

void* random_array_choice(CScriptArray* array, random_interface* rng) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	if (!rng) rng = get_default_random();
	return array->At(rng->range(0, array->GetSize() - 1));
}

void random_array_choice_wrapper(asIScriptGeneric* gen) {
	CScriptArray* array = (CScriptArray*)gen->GetObject();
	random_interface* rng = (random_interface*)gen->GetArgObject(0);
	void* result = random_array_choice(array, rng);
	if (result)
		gen->SetReturnAddress(result);
	else
		gen->SetReturnAddress(nullptr);
}

void random_array_shuffle(CScriptArray* array, random_interface* rng) {
	if (!rng) rng = get_default_random();
	if (array->GetSize() < 2) return;
	// Use temporary slot for swapping
	array->Resize(array->GetSize() + 1);
	for (uint32 i = array->GetSize() - 2; i > 0; i--) {
		int32 j = rng->range(0, i);
		array->SetValue(array->GetSize() - 1, array->At(i));
		array->SetValue(i, array->At(j));
		array->SetValue(j, array->At(array->GetSize() - 1));
	}
	array->Resize(array->GetSize() - 1);
}

void* random_script_array_choice(CScriptArray* array, asIScriptObject* scriptRng) {
	if (array->GetSize() == 0) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx) ctx->SetException("Cannot get random element from empty array");
		return nullptr;
	}
	if (!scriptRng) {
		random_interface* defaultRng = get_default_random();
		return array->At(defaultRng->range(0, array->GetSize() - 1));
	}
	asIScriptEngine* engine = scriptRng->GetEngine();
	asIScriptContext* ctx = engine->CreateContext();
	asIScriptFunction* rangeFunc = scriptRng->GetObjectType()->GetMethodByDecl("int range(int, int)");
	if (rangeFunc && ctx) {
		ctx->Prepare(rangeFunc);
		ctx->SetObject(scriptRng);
		ctx->SetArgDWord(0, 0);
		ctx->SetArgDWord(1, array->GetSize() - 1);
		ctx->Execute();
		int32 index = ctx->GetReturnDWord();
		ctx->Release();
		return array->At(index);
	}
	if (ctx) ctx->Release();
	random_interface* defaultRng = get_default_random();
	return array->At(defaultRng->range(0, array->GetSize() - 1));
}

void random_script_array_choice_wrapper(asIScriptGeneric* gen) {
	CScriptArray* array = (CScriptArray*)gen->GetObject();
	asIScriptObject* scriptRng = (asIScriptObject*)gen->GetArgObject(0);
	void* result = random_script_array_choice(array, scriptRng);
	if (result)
		gen->SetReturnAddress(result);
	else
		gen->SetReturnAddress(nullptr);
}

void random_script_array_shuffle(CScriptArray* array, asIScriptObject* scriptRng) {
	if (!scriptRng) {
		random_interface* defaultRng = get_default_random();
		random_array_shuffle(array, defaultRng);
		return;
	}
	if (array->GetSize() < 2) return;
	asIScriptEngine* engine = scriptRng->GetEngine();
	asIScriptContext* ctx = engine->CreateContext();
	asIScriptFunction* rangeFunc = scriptRng->GetObjectType()->GetMethodByDecl("int range(int, int)");
	if (rangeFunc && ctx) {
		// Use temporary slot for swapping
		array->Resize(array->GetSize() + 1);
		for (uint32 i = array->GetSize() - 2; i > 0; i--) {
			ctx->Prepare(rangeFunc);
			ctx->SetObject(scriptRng);
			ctx->SetArgDWord(0, 0);
			ctx->SetArgDWord(1, i);
			ctx->Execute();
			int32 j = ctx->GetReturnDWord();
			array->SetValue(array->GetSize() - 1, array->At(i));
			array->SetValue(i, array->At(j));
			array->SetValue(j, array->At(array->GetSize() - 1));
		}
		array->Resize(array->GetSize() - 1);
		ctx->Release();
	} else {
		if (ctx) ctx->Release();
		random_interface* defaultRng = get_default_random();
		random_array_shuffle(array, defaultRng);
	}
}
