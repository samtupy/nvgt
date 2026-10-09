/* random_interface.h - object-oriented random number generator interface
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

#pragma once

#include <rnd.h>

#include <cstdint>
#include <memory>
#include <string>

// Type definitions
typedef uint32_t uint32;
typedef int32_t int32;
typedef uint64_t uint64;
typedef int64_t int64;
typedef uint8_t uint8;
typedef float float32;

class CScriptArray;
class asIScriptObject;

class asIScriptFunction;
class asIScriptContext;

// Base interface for random number generators
class random_interface {
public:
	virtual ~random_interface() = default;
	virtual uint32 next() = 0;
	virtual int64 next64() {
		return static_cast<int64>(next());
	}
	virtual float32 nextf() = 0;
	virtual int32 range(int32 min, int32 max) = 0;

	virtual int64 range64(int64 min, int64 max) {
		return static_cast<int64>(range(static_cast<int32>(min), static_cast<int32>(max)));
	}
	
	virtual void seed(uint32 s) = 0;
	virtual void seed64(uint64 s) { seed(static_cast<uint32>(s)); }
	virtual std::string get_state() const = 0;
	virtual bool set_state(const std::string& state) = 0;
	virtual void add_ref() = 0;
	virtual void release() = 0;

	// Utility functions (with default implementations)
	virtual bool next_bool(int32 percent = 50);
	virtual std::string next_character(const std::string& min, const std::string& max);
};

class script_random_wrapper;

// C++ RNG implementations
class random_pcg : public random_interface {
private:
	rnd_pcg_t gen;
	int32 ref_count;

public:
	random_pcg();
	random_pcg(uint32 s);
	uint32 next() override;
	float32 nextf() override;
	int32 range(int32 min, int32 max) override;
	void seed(uint32 s) override;
	std::string get_state() const override;
	bool set_state(const std::string& state) override;
	void add_ref() override;
	void release() override;
};

class random_well : public random_interface {
private:
	rnd_well_t gen;
	int32 ref_count;

public:
	random_well();
	random_well(uint32 s);
	uint32 next() override;
	float32 nextf() override;
	int32 range(int32 min, int32 max) override;
	void seed(uint32 s) override;
	std::string get_state() const override;
	bool set_state(const std::string& state) override;
	void add_ref() override;
	void release() override;
};

class random_gamerand : public random_interface {
private:
	rnd_gamerand_t gen;
	int32 ref_count;

public:
	random_gamerand();
	random_gamerand(uint32 s);
	uint32 next() override;
	float32 nextf() override;
	int32 range(int32 min, int32 max) override;
	void seed(uint32 s) override;
	std::string get_state() const override;
	bool set_state(const std::string& state) override;
	void add_ref() override;
	void release() override;
};

class random_xorshift : public random_interface {
private:
	rnd_xorshift_t gen;
	int32 ref_count;

public:
	random_xorshift();
	random_xorshift(uint64 s);
	uint32 next() override;
	int64 next64() override;
	float32 nextf() override;
	int32 range(int32 min, int32 max) override;
	int64 range64(int64 min, int64 max) override;
	void seed(uint32 s) override;
	void seed64(uint64 s) override;
	std::string get_state() const override;
	bool set_state(const std::string& state) override;
	void add_ref() override;
	void release() override;
};

extern random_xorshift* g_random_xorshift;
extern random_interface* g_default_random;
void set_default_random(random_interface* rng);
void set_default_random_script(asIScriptObject* scriptObj);
random_interface* get_default_random();
void cleanup_default_random();
void init_default_random(random_interface* rng);

random_pcg* random_pcg_factory();
random_pcg* random_pcg_factory_seed(uint32 seed);
random_well* random_well_factory();
random_well* random_well_factory_seed(uint32 seed);
random_gamerand* random_gamerand_factory();
random_gamerand* random_gamerand_factory_seed(uint32 seed);
random_xorshift* random_xorshift_factory();
random_xorshift* random_xorshift_factory_seed_uint(uint32 seed);
random_xorshift* random_xorshift_factory_seed(uint64 seed);

void* random_array_choice(CScriptArray* array, random_interface* rng);
void random_array_shuffle(CScriptArray* array, random_interface* rng);
void* random_script_array_choice(CScriptArray* array, asIScriptObject* scriptRng);
void random_script_array_shuffle(CScriptArray* array, asIScriptObject* scriptRng);

class asIScriptGeneric;
void random_array_choice_wrapper(asIScriptGeneric* gen);
void random_script_array_choice_wrapper(asIScriptGeneric* gen);
