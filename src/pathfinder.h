/* pathfinder.h - pathfinder implementation header
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

#include <unordered_map>
#include <string>
#include <vector>
#include <angelscript.h>
#include <micropather.h>
#include "scriptarray.h"
#include "scriptany.h"
#include "nvgt.h"

class hashpoint {
	// https://stackoverflow.com/questions/16792751/hashmap-for-2d3d-coordinates-i-e-vector-of-ints/47928817
public:
	hashpoint(int x, int y, int z) : x(x), y(y), z(z) {};
	int x, y, z;
};
struct hashpoint_hash {
	size_t operator()(const hashpoint& p) const {
		// Morton code hash function for 3D points with negative coordinate support provided by chat gpt.
		// Translate the coordinates so that the minimum value is 0
		const int min_xy = (p.x < p.y ? p.x : p.y);
		const int min_coord = min_xy < p.z ? min_xy : p.z;
		const uint32_t x = static_cast<uint32_t>(p.x - min_coord);
		const uint32_t y = static_cast<uint32_t>(p.y - min_coord);
		const uint32_t z = static_cast<uint32_t>(p.z - min_coord);

		// Interleave the bits of each coordinate
		uint32_t xx = x;
		uint32_t yy = y;
		uint32_t zz = z;
		xx = (xx | (xx << 16)) & 0x030000FF;
		xx = (xx | (xx << 8)) & 0x0300F00F;
		xx = (xx | (xx << 4)) & 0x030C30C3;
		xx = (xx | (xx << 2)) & 0x09249249;
		yy = (yy | (yy << 16)) & 0x030000FF;
		yy = (yy | (yy << 8)) & 0x0300F00F;
		yy = (yy | (yy << 4)) & 0x030C30C3;
		yy = (yy | (yy << 2)) & 0x09249249;
		zz = (zz | (zz << 16)) & 0x030000FF;
		zz = (zz | (zz << 8)) & 0x0300F00F;
		zz = (zz | (zz << 4)) & 0x030C30C3;
		zz = (zz | (zz << 2)) & 0x09249249;

		// Combine the interleaved bits into a single hash value and add back the minimum coordinate value
		const size_t hash_val = static_cast<size_t>((xx << 2) | (yy << 1) | zz);
		return hash_val + static_cast<size_t>(min_coord);
	}
};
struct hashpoint_equals {
	bool operator()(const hashpoint& lhs, const hashpoint& rhs) const {
		return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z);
	}
};
typedef std::unordered_map<hashpoint, void*, hashpoint_hash, hashpoint_equals> hashpoint_map;
typedef std::unordered_map<hashpoint, float, hashpoint_hash, hashpoint_equals> hashpoint_float_map;
class pathfinder : public micropather::Graph {
	hashpoint_float_map difficulty_cache[11];
	micropather::MicroPather* pf;
	int RefCount;
	asIScriptFunction* callback;
	CScriptAny* callback_data;
	bool abort;
	bool must_reset;
	bool gc_flag;
public:
	bool solving;
	int desperation_factor;
	bool allow_diagonals;
	bool automatic_reset;
	int search_range;
	float total_cost;
	int start_x, start_y, start_z;
	pathfinder(int size = 1024, bool cache = true);
	int AddRef();
	int Release();
	void enum_references(asIScriptEngine* engine);
	void release_all_handles(asIScriptEngine* engine);
	int get_ref_count();
	void set_gc_flag();
	bool get_gc_flag();
	void set_callback_function(asIScriptFunction* func);
	float get_difficulty(void* state);
	float get_difficulty(int x, int y, int z);
	void cancel();
	void reset();
	CScriptArray* find(int start_x, int start_y, int start_z, int end_x, int end_y, int end_z, CScriptAny* data);
	virtual float LeastCostEstimate(void* nodeStart, void* nodeEnd);
	virtual void AdjacentCost(void* node, micropather::MPVector<micropather::StateCost>* neighbors);
	virtual void PrintStateInfo(void* state) {
		return;
	}
};

void RegisterScriptPathfinder(asIScriptEngine* engine);
