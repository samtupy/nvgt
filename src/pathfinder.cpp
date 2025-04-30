/* pathfinder.cpp - pathfinder implementation code
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

#include <cstring>
#include <algorithm>
#include <reactphysics3d/reactphysics3d.h>
#include "pathfinder.h"
#include <cmath>
using namespace std;
static asITypeInfo* VectorArrayType = NULL;
static asITypeInfo* StringType = nullptr;
#define NODE_BIT_SIZE 19
inline void* encode_state(int64_t x, int64_t y, int64_t z, int64_t d) {
	int mc = (1 << NODE_BIT_SIZE) - 1;
	x += 10000;
	y += 10000;
	z += 10000;
	if (x < 0 || x > mc || y < 0 || y > mc || z < 0 || z > mc)
		return NULL;
	uint64_t s = x + (y << NODE_BIT_SIZE) + (z << (NODE_BIT_SIZE * 2)) + (d << NODE_BIT_SIZE * 3);
	return (void*)s;
}
inline hashpoint decode_state(void* st) {
	int mc = (1 << NODE_BIT_SIZE) - 1;
	uint64_t s = reinterpret_cast<uint64_t>(st);
	return hashpoint((s & mc) - 10000, (s >> NODE_BIT_SIZE & mc) - 10000, (s >> NODE_BIT_SIZE * 2 & mc) - 10000);
}
inline void decode_state(void* st, int* x, int* y, int* z) {
	int mc = (1 << NODE_BIT_SIZE) - 1;
	uint64_t s = reinterpret_cast<uint64_t>(st);
	*x = (s & mc) - 10000;
	*y = (s >> NODE_BIT_SIZE & mc) - 10000;
	*z = (s >> NODE_BIT_SIZE * 2 & mc) - 10000;
}

pathfinder::pathfinder(int size, bool cache) : gc_flag(false) {
	pf = new micropather::MicroPather(this, size, 10, cache);
	callback = NULL;
	callback_data = NULL;
	RefCount = 1;
	desperation_factor = 0;
	allow_diagonals = false;
	must_reset = false;
	search_range = 0;
	abort = false;
	solving = false;
	total_cost = 0;
	automatic_reset = false;
	this->cache = cache;
	asIScriptContext* ctx = asGetActiveContext();
	if (ctx)
		ctx->GetEngine()->NotifyGarbageCollectorOfNewObject(this, ctx->GetEngine()->GetTypeInfoByName("pathfinder"));
	callback_mode = CALLBACK_SIMPLE;
}
int pathfinder::AddRef() {
	gc_flag = false;
	return asAtomicInc(RefCount);
}
int pathfinder::Release() {
	gc_flag = false;
	if (asAtomicDec(RefCount) == 0) {
		release_all_handles(nullptr);
		reset();
		delete pf;
		delete this;
		return 0;
	}
	return RefCount;
}
int pathfinder::get_ref_count() {
	return RefCount;
}
void pathfinder::enum_references(asIScriptEngine* engine) {
	if (callback)
		engine->GCEnumCallback(callback);
	if (callback_data)
		engine->GCEnumCallback(callback_data);
}
void pathfinder::release_all_handles(asIScriptEngine* engine) {
	if (callback)
		callback->Release();
	if (callback_data)
		callback_data->Release();
	callback = nullptr;
	callback_data = nullptr;
}
void pathfinder::set_gc_flag() {
	gc_flag = true;
}
bool pathfinder::get_gc_flag() {
	return gc_flag;
}
void pathfinder::set_callback_function(asIScriptFunction* func) {
	if (callback)
		callback->Release();
	if (func)
		callback = func;
	callback_mode = CALLBACK_SIMPLE;
}
void pathfinder::set_callback_function_ex(asIScriptFunction* func) {
	// This callback type is fundamentally incompatible with path caching.
	if (cache) {
		asGetActiveContext()->SetException("A callback with parent state support cannot be used with path caching enabled.");
		return;
	}
	set_callback_function(func);
	callback_mode = CALLBACK_ADVANCED;
}
void pathfinder::set_callback_function_legacy(asIScriptFunction* func) {
	// This callback type is also fundamentally incompatible with path caching.
	if (cache) {
		asGetActiveContext()->SetException("A legacy callback cannot be used with path caching enabled.");
		return;
	}
	set_callback_function(func);
	callback_mode = CALLBACK_LEGACY;
}

float pathfinder::get_difficulty(void* state, void* parent_state) {
	if (!callback)
		return FLT_MAX;
	int x, y, z;
	int parent_x, parent_y, parent_z;
	decode_state(state, &x, &y, &z);
	decode_state(parent_state, &parent_x, &parent_y, &parent_z);
	return get_difficulty(x, y, z, parent_x, parent_y, parent_z);
}
float pathfinder::get_difficulty(int x, int y, int z, int parent_x, int parent_y, int parent_z) {
	hashpoint pt(x, y, z);
	hashpoint_float_map::iterator n = difficulty_cache[desperation_factor].find(pt);
	if (n != difficulty_cache[desperation_factor].end())
		return n->second;
	if (abort)
		return FLT_MAX;
	asIScriptContext* ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext* ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
	if (!ctx)
		return FLT_MAX;
	if (ctx->Prepare(callback) < 0) {
		if (new_context)
			g_ScriptEngine->ReturnContext(ctx);
		else
			ctx->PopState();
		return FLT_MAX;
	}
	switch (callback_mode) {
		case CALLBACK_SIMPLE:
			ctx->SetArgDWord(0, x);
			ctx->SetArgDWord(1, y);
			ctx->SetArgDWord(2, z);
			ctx->SetArgObject(3, callback_data);
			break;
		case CALLBACK_ADVANCED:
			ctx->SetArgDWord(0, x);
			ctx->SetArgDWord(1, y);
			ctx->SetArgDWord(2, z);
			ctx->SetArgDWord(3, parent_x);
			ctx->SetArgDWord(4, parent_y);
			ctx->SetArgDWord(5, parent_z);
			ctx->SetArgObject(6, callback_data);
			break;
		case CALLBACK_LEGACY:
			ctx->SetArgDWord(0, x);
			ctx->SetArgDWord(1, y);
			ctx->SetArgDWord(2, parent_x);
			ctx->SetArgDWord(3, parent_y);
			string ud;
			if (StringType == nullptr)
				StringType = g_ScriptEngine->GetTypeInfoByDecl("string");
			if (callback_data != nullptr)
				callback_data->Retrieve((void*)&ud, StringType->GetTypeId());
			ctx->SetArgObject(4, (void*)&ud);
	}
	if (ctx->Execute() != asEXECUTION_FINISHED) {
		if (new_context)
			g_ScriptEngine->ReturnContext(ctx);
		else
			ctx->PopState();
		return FLT_MAX;
	}
	int v = ctx->GetReturnDWord();
	if (v < 10)
		v -= desperation_factor;
	if (v < 0)
		v = 0;
	float val = (v < 10 ? v : FLT_MAX);
	difficulty_cache[desperation_factor][pt] = val;
	if (new_context)
		g_ScriptEngine->ReturnContext(ctx);
	else
		ctx->PopState();
	return val;
}
void pathfinder::cancel() {
	if (solving) {
		abort = true;
		must_reset = true;
	}
}
void pathfinder::reset() {
	if (solving) {
		abort = true;
		must_reset = true;
		return;
	}
	for (int i = 0; i < 11; i++)
		difficulty_cache[i].clear();
	pf->Reset();
}
CScriptArray* pathfinder::find(int start_x, int start_y, int start_z, int end_x, int end_y, int end_z, CScriptAny* data) {
	if (!VectorArrayType)
		VectorArrayType = g_ScriptEngine->GetTypeInfoByDecl("array<vector>");
	CScriptArray* array = CScriptArray::Create(VectorArrayType);
	if (solving)
		return array;
	abort = false;
	must_reset = false;
	total_cost = 0;
	if (!callback)
		return array;
	if (search_range > 0 && allow_diagonals && hypot(end_x - start_x, end_y - start_y, end_z - start_z) > search_range || search_range > 0 && !allow_diagonals && (abs(end_x - start_x) + abs(end_y - start_y) + abs(end_z - start_z)) > search_range)
		return array;
	if (automatic_reset || !cache)
		reset();
	callback_data = data;
	if (data)
		data->AddRef();
	// Only perform this fast-fail optimization if callback is "simple", otherwise it will just produce false positives.
	if (callback_mode == CALLBACK_SIMPLE && (get_difficulty(start_x, start_y, start_z, start_x, start_y, start_z) > 9 || get_difficulty(end_x, end_y, end_z, end_x, end_y, end_z) > 9))
		return array;
	void* start = encode_state(start_x, start_y, start_z, desperation_factor);
	this->start_x = start_x;
	this->start_y = start_y;
	this->start_z = start_z;
	void* end = encode_state(end_x, end_y, end_z, desperation_factor);
	micropather::MPVector<void*> path;
	solving = true;
	int result = pf->Solve(start, end, &path, &total_cost);
	solving = false;
	if (data)
		data->Release();
	callback_data = NULL;
	if (abort || must_reset || result != micropather::MicroPather::SOLVED) {
		abort = false;
		total_cost = 0;
		if (must_reset)
			reset();
		return array;
	}
	array->Reserve(path.size() - 1);
	reactphysics3d::Vector3 v;
	int x, y, z;
	// BGT did not include the starting location here. Changing to match for now; discussion welcome.
	for (int i = 1; i < path.size(); i++) {
		decode_state(path[i], &x, &y, &z);
		v.setAllValues(x, y, z);
		array->InsertLast(&v);
	}
	return array;
}
CScriptArray* pathfinder::find_legacy(int start_x, int start_y, int parent_x, int parent_y, string user_data) {
	if (callback_mode != CALLBACK_LEGACY)
		return nullptr;
	if (StringType == nullptr)
		StringType = g_ScriptEngine->GetTypeInfoByDecl("string");
	CScriptAny* ud = new CScriptAny(g_ScriptEngine);
	ud->Store((void*)&user_data, StringType->GetTypeId());
	CScriptArray* result = find(start_x, start_y, 0, parent_x, parent_y, 0, ud);
	ud->Release();
	return result;
}
float pathfinder::LeastCostEstimate(void* nodeStart, void* nodeEnd) {
	int start_x, start_y, start_z, end_x, end_y, end_z;
	decode_state(nodeStart, &start_x, &start_y, &start_z);
	decode_state(nodeEnd, &end_x, &end_y, &end_z);
	float x = end_x - start_x;
	float y = end_y - start_y;
	float z = end_z - start_z;
	float d = get_difficulty(end_x, end_y, end_z, end_x, end_y, end_z);
	if (d > 9)
		return FLT_MAX;
	if (allow_diagonals)
		return hypot(x, y, z);
	else
		return (abs(x) + abs(y) + abs(z));
}
void pathfinder::AdjacentCost(void* node, micropather::MPVector<micropather::StateCost>* neighbors) {
	int x, y, z;
	decode_state(node, &x, &y, &z);
	const int dx[18] = {1, 1, 0, -1, -1, -1, 0, 1, 0, 0, 1, -1, 0, 0, 1, -1, 0, 0};
	const int dy[18] = {0, 1, 1, 1, 0, -1, -1, -1, 0, 0, 0, 0, 1, -1, 0, 0, 1, -1};
	const float cost[18] = {1.0f, 1.41f, 1.0f, 1.41f, 1.0f, 1.41f, 1.0f, 1.41f, 1.0f, 1.0f, 1.41f, 1.41f, 1.41f, 1.41f, 1.41f, 1.41f, 1.41f, 1.41f};
	for (int i = 0; i < 18; ++i) {
		int nx = x + dx[i];
		int ny = y + dy[i];
		int nz = i >= 8 && i != 9 && i < 14 ? z + 1 : (i == 9 || i >= 14 ? z - 1 : z);
		void* st = encode_state(nx, ny, nz, desperation_factor);
		if (search_range > 0 && (nx < start_x - search_range || nx > start_x + search_range || ny < start_y - search_range || ny > start_y + search_range || nz < start_z - search_range || nz > start_z + search_range)) {
			/*
			micropather::StateCost cost={st, FLT_MAX};
			neighbors->push_back(cost);
			*/
			must_reset = true;
			continue;
		}
		// If we're not allowing diagonals, then diagonals are not neighbours.
		if (!allow_diagonals && abs(((abs(nx) + abs(ny) + abs(nz)) - (abs(x) + abs(y) + abs(z)))) != 1)
			continue;
		// If we're in legacy (2D) mode, save some unnecessary calls into script by rejecting nonzero Z right here.
		if (callback_mode == CALLBACK_LEGACY && (z != 0 || nz != 0))
			continue;
		float c = get_difficulty(nx, ny, nz, x, y, z);
		if (c != FLT_MAX)
			c++;
		if (c > 10)
			c = FLT_MAX;
		else
			c *= cost[i];
		if (c != FLT_MAX) {
			micropather::StateCost cost = {st, c};
			neighbors->push_back(cost);
		}
	}
}

pathfinder* new_pathfinder(int size, bool cache) {
	return new pathfinder(size, cache);
}
void RegisterScriptPathfinder(asIScriptEngine* engine) {
	engine->RegisterObjectType("pathfinder", 0, asOBJ_REF | asOBJ_GC);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_FACTORY, "pathfinder @p(int = 1024, bool = true)", asFUNCTION(new_pathfinder), asCALL_CDECL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_ADDREF, "void f()", asMETHOD(pathfinder, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_RELEASE, "void f()", asMETHOD(pathfinder, Release), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_GETREFCOUNT, "int f()", asMETHOD(pathfinder, get_ref_count), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_SETGCFLAG, "void f()", asMETHOD(pathfinder, set_gc_flag), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_GETGCFLAG, "bool f()", asMETHOD(pathfinder, get_gc_flag), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_ENUMREFS, "void f(int&in)", asMETHOD(pathfinder, enum_references), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pathfinder", asBEHAVE_RELEASEREFS, "void f(int&in)", asMETHOD(pathfinder, release_all_handles), asCALL_THISCALL);
	engine->RegisterObjectProperty("pathfinder", "const bool solving", asOFFSET(pathfinder, solving));
	engine->RegisterObjectProperty("pathfinder", "const float total_cost", asOFFSET(pathfinder, total_cost));
	engine->RegisterObjectProperty("pathfinder", "int desperation_factor", asOFFSET(pathfinder, desperation_factor));
	engine->RegisterObjectProperty("pathfinder", "bool allow_diagonals", asOFFSET(pathfinder, allow_diagonals));
	engine->RegisterObjectProperty("pathfinder", "bool automatic_reset", asOFFSET(pathfinder, automatic_reset));
	engine->RegisterObjectProperty("pathfinder", "int search_range", asOFFSET(pathfinder, search_range));
	engine->RegisterFuncdef("int pathfinder_callback(int, int, int, any@ = null)");
	engine->RegisterFuncdef("int pathfinder_callback_ex(int, int, int, int, int, int, any@ = null)");
	engine->RegisterFuncdef("int pathfinder_callback_legacy(int, int, int, int, string)");
	engine->RegisterObjectMethod("pathfinder", "void set_callback_function(pathfinder_callback@)", asMETHOD(pathfinder, set_callback_function), asCALL_THISCALL);
	engine->RegisterObjectMethod("pathfinder", "void set_callback_function(pathfinder_callback_ex@)", asMETHOD(pathfinder, set_callback_function_ex), asCALL_THISCALL);
	engine->RegisterObjectMethod("pathfinder", "void cancel()", asMETHOD(pathfinder, cancel), asCALL_THISCALL);
	engine->RegisterObjectMethod("pathfinder", "void set_callback_function(pathfinder_callback_legacy@)", asMETHOD(pathfinder, set_callback_function_legacy), asCALL_THISCALL);
	engine->RegisterObjectMethod("pathfinder", "void reset()", asMETHOD(pathfinder, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod("pathfinder", "vector[]@ find(int, int, int, int, int, int, any@+ = null)", asMETHOD(pathfinder, find), asCALL_THISCALL);
	engine->RegisterObjectMethod("pathfinder", "vector[]@ find(int, int, int, int, string = \"\")", asMETHOD(pathfinder, find_legacy), asCALL_THISCALL);
}
