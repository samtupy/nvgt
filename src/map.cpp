/* map.cpp - coordinate map implementation code
 * At this time, anything having to do with rotation may be unstable.
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

#define NOMINMAX
#define _USE_MATH_DEFINES
#include <cmath>
#include "map.h"
#include <algorithm>
#include <obfuscate.h>
#include <limits>
#include "scriptstuff.h"

using reactphysics3d::Vector3;

static asIScriptContext* fcallback_ctx = NULL;

Vector3 rotate(const Vector3& p, const Vector3& o, double theta, bool maintain_z = true) {
	int angle = (180.0 / M_PI) * theta;
	Vector3 r;
	Vector3 cs = Vector3(angle != 90 && angle != 270 ? cos(theta) : 0, angle != 180 ? sin(theta) : 0, 0);
	r.x = (cs.x * (p.x - o.x)) - (cs.y * (p.y - o.y)) + o.x;
	r.y = (cs.y * (p.x - o.x)) + (cs.x * (p.y - o.y)) + o.y;
	if (maintain_z)
		r.z = p.z;
	return r;
}
Vector3 get_center(Vector3 _min, Vector3 _max) {
	if (_min == _max || _max.x - _min.x < 2 && _max.y - _min.y < 2 && _max.z - _min.z < 2)
		return _min;
	return Vector3(_min.x + (_max.x - _min.x) / 2.0, _min.y + (_max.y - _min.y) / 2.0, _min.z + (_max.z - _min.z) / 2.0);
}
Vector3 get_center(double minx, double maxx, double miny, double maxy, double minz, double maxz) {
	if (minx == maxx && miny == maxy && minz == maxz || maxx - minx < 2 && maxy - miny < 2 && maxz - minz < 2)
		return Vector3(minx, miny, minz);
	return Vector3(minx + (maxx - minx) / 2.0, miny + (maxy - miny) / 2.0, minz + (maxz - minz) / 2.0);
}

// following function in a round about way from https://stackoverflow.com/questions/10962379/how-to-check-intersection-between-2-rotated-rectangles
bool polygons_intersect(const std::vector<Vector3>& a, const std::vector<Vector3>& b) {
	for (int polyi = 0; polyi < 2; ++polyi) {
		const std::vector<Vector3>& polygon = polyi == 0 ? a : b;
		for (int i1 = 0; i1 < polygon.size(); ++i1) {
			const int i2 = (i1 + 1) % polygon.size();
			const double normalx = polygon[i2].y - polygon[i1].y;
			const double normaly = polygon[i2].x - polygon[i1].x;
			double minA = (std::numeric_limits<double>::max());
			double maxA = (std::numeric_limits<double>::min());
			for (int ai = 0; ai < a.size(); ++ai) {
				const double projected = normalx * a[ai].x + normaly * a[ai].y;
				if (projected < minA) minA = projected;
				if (projected > maxA) maxA = projected;
			}
			double minB = std::numeric_limits<double>::max();
			double maxB = std::numeric_limits<double>::min();
			for (int bi = 0; bi < b.size(); ++bi) {
				const double projected = normalx * b[bi].x + normaly * b[bi].y;
				if (projected < minB) minB = projected;
				if (projected > maxB) maxB = projected;
			}
			if (maxA < minB || maxB < minA)
				return false;
		}
	}
	return true;
}
bool boxes_intersect(float minx1, float maxx1, float miny1, float maxy1, float r1, float minx2, float maxx2, float miny2, float maxy2, float r2) {
	Vector3 c1 = get_center(minx1, maxx1 + 1, miny1, maxy1 + 1, 0, 0);
	Vector3 c2 = get_center(minx2, maxx2, miny2, maxy2, 0, 0);
	Vector3 min1 = Vector3(minx1, miny1, 0);
	Vector3 min2 = Vector3(minx2, miny2, 0);
	std::vector<Vector3> p1 = {min1 + rotate(Vector3(-c1.x, -c1.y, 0), Vector3(0, 0, 0), r1), min1 + rotate(Vector3(-c1.x, c1.y, 0), Vector3(0, 0, 0), r1), min1 + rotate(Vector3(c1.x, c1.y, 0), Vector3(0, 0, 0), r1), min1 + rotate(Vector3(c1.x, -c1.y, 0), Vector3(0, 0, 0), r1)};
	std::vector<Vector3> p2 = {min2 + rotate(Vector3(-c2.x, -c2.y, 0), Vector3(0, 0, 0), r2), min2 + rotate(Vector3(-c2.x, c2.y, 0), Vector3(0, 0, 0), r2), min2 + rotate(Vector3(c2.x, c2.y, 0), Vector3(0, 0, 0), r2), min2 + rotate(Vector3(c2.x, -c2.y, 0), Vector3(0, 0, 0), r2)};
	return polygons_intersect(p1, p2);
}

static asITypeInfo* g_MapAreaArrayType = NULL;

int frame_sizes[] = {8192, 256, 32, 0};
int get_frame_size(float x, float y, float z) {
	for (int i = 0; frame_sizes[i]; i++) {
		if (i == total_frame_sizes - 1 || x >= frame_sizes[i] || y >= frame_sizes[i] || z >= frame_sizes[i]) return i;
	}
	return total_frame_sizes - 1;
}

static bool map_area_sort(map_area* a1, map_area* a2) {
	return a1 == NULL || a2 == NULL || a1->priority < a2->priority;
}

map_area::map_area(coordinate_map* p, float minx, float maxx, float miny, float maxy, float minz, float maxz, float rotation, CScriptAny* primary_data, const std::string& data1, const std::string& data2, const std::string& data3, int priority, asINT64 flags) : parent(p), minx(minx), maxx(maxx), miny(miny), maxy(maxy), minz(minz), maxz(maxz), rotation(rotation), framesize(0), primary_data(primary_data), data1(data1), data2(data2), data3(data3), priority(priority), flags(flags), framed(false), tmp_adding_to_result(false), ref_count(1) {
	center = get_center(minx, maxx, miny, maxy, minz, maxz);
	reframe();
}
void map_area::add_ref() {
	asAtomicInc(ref_count);
}
void map_area::release() {
	if (asAtomicDec(ref_count) < 1) {
		if (primary_data)
			primary_data->Release();
		delete this;
	}
}
bool map_area::is_unfiltered(asIScriptFunction* filter_callback) {
	if (filter_callback == NULL) return true;
	asIScriptContext* ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext* ctx = NULL;
	if (new_context) {
		if (!fcallback_ctx) fcallback_ctx = g_ScriptEngine->RequestContext();
		ctx = fcallback_ctx;
	} else ctx = ACtx;
	bool ret = true;
	if (!ctx || ctx->Prepare(filter_callback) < 0 || ctx->SetArgObject(0, this) < 0 || ctx->Execute() != asEXECUTION_FINISHED) {
		if (!new_context && ctx) ctx->PopState();
		return true;
	}
	profiler_last_func = NULL;
	ret = ctx->GetReturnByte() != 0;
	if (!new_context) ctx->PopState();
	return ret;
}
void map_area::unframe() {
	if (!parent || !framesize || !framed) return;
	for (map_frame* f : frames) {
		auto it = std::find(f->areas.begin(), f->areas.end(), this);
		while (it != f->areas.end()) {
			f->areas.erase(it);
			if (ref_count > 1) release();
			it = std::find(f->areas.begin(), f->areas.end(), this);
		}
	}
	framed = false;
	frames.clear();
}
void map_area::reframe() {
	if (!parent || framed) return;
	if (!framesize) framesize = get_frame_size(maxx - minx, maxy - miny, maxz - minz);
	Vector3 MIN = Vector3(minx, miny, minz);
	Vector3 MAX = Vector3(maxx, maxy, maxz);
	if (rotation > 0) {
		Vector3 d = MAX - MIN;
		std::vector<Vector3> points = {rotate(MIN, center, rotation), rotate(Vector3(MIN.x + d.x, MIN.y, 0), center, rotation), rotate(Vector3(MIN.x, MIN.y + d.y, 0), center, rotation), rotate(Vector3(MIN.x + d.x, MIN.y + d.y, 0), center, rotation)};
		for (int i = 0; i < points.size(); i++) {
			if (points[i].x < MIN.x) MIN.x = points[i].x - 1;
			else if (points[i].x > MAX.x) MAX.x = points[i].x + 1;
			if (points[i].y < MIN.y) MIN.y = points[i].y - 1;
			else if (points[i].y > MAX.y) MAX.y = points[i].y + 1;
		}
	}
	for (int x = MIN.x; x <= MAX.x + frame_sizes[framesize]; x += frame_sizes[framesize]) {
		for (int y = MIN.y; y <= MAX.y + frame_sizes[framesize]; y += frame_sizes[framesize]) {
			for (int z = MIN.z; z <= MAX.z + frame_sizes[framesize]; z += frame_sizes[framesize]) {
				map_frame* f = parent->get_frame(x, y, z, framesize);
				if (!f) continue;
				add_ref();
				f->areas.push_back(this);
				frames.push_back(f);
			}
		}
	}
	framed = true;
}
void map_area::set(float minx, float maxx, float miny, float maxy, float minz, float maxz, float rotation) {
	bool was_framed = framed;
	unframe();
	this->minx = minx;
	this->maxx = maxx;
	this->miny = miny;
	this->maxy = maxy;
	this->minz = minz;
	this->maxz = maxz;
	this->rotation = rotation;
	center = get_center(minx, maxx, miny, maxy, minz, maxz);
	if (was_framed) reframe();
}
void map_area::set_area(float minx, float maxx, float miny, float maxy, float minz, float maxz) {
	set(minx, maxx, miny, maxy, minz, maxz, rotation);
}
void map_area::set_rotation(float rotation) {
	set(minx, maxx, miny, maxy, minz, maxz, rotation);
}
bool map_area::is_in_area(float x, float y, float z, float d, asIScriptFunction* filter_callback, asINT64 required_flags, asINT64 excluded_flags) {
	bool flag_filter = ((flags & required_flags) == required_flags) && ((flags & excluded_flags) == 0);
	if (!flag_filter) return false;
	if (z < minz - d || z >= maxz + d + 1) return false;
	if (d > 1 && (z < minz || z >= maxz + 1)) {
		int longest = maxx - minx;
		if (maxy - miny > longest) longest = maxy - miny;
		if (longest < 1) longest = 1;
		return x >= center.x - d - longest && x <= center.x + d + longest && y >= center.y - d - longest && y <= center.y + d + longest && is_unfiltered(filter_callback);
	}
	Vector3 border = Vector3(1, 1, 1);
	if (rotation > 0) {
		Vector3 r = rotate(Vector3(x, y, z), center, rotation);
		x = r.x;
		y = r.y;
		//border=rotate(border, Vector3(0, 0, 0), rotation);
	}
	if (x < minx - d + (border.x < 0 ? border.x : 0) || x >= maxx + d + (border.x > 0 ? border.x : 0)) return false;
	if (y < miny - d + (border.y < 0 ? border.y : 0) || y >= maxy + d + (border.y > 0 ? border.y : 0)) return false;
	if (z < minz - d + (border.z < 0 ? border.z : 0) || z >= maxz + d + (border.z > 0 ? border.z : 0)) return false;
	return is_unfiltered(filter_callback);
}
bool map_area::is_in_area_range(float minx, float maxx, float miny, float maxy, float minz, float maxz, float d, float r, asIScriptFunction* filter_callback, asINT64 required_flags, asINT64 excluded_flags) {
	bool flag_filter = ((flags & required_flags) == required_flags) && ((flags & excluded_flags) == 0);
	if (!flag_filter) return false;
	if (minx == maxx && miny == maxy && minz == maxz) return is_in_area(minx, miny, minz, d, filter_callback);
	else if (this->minx == this->maxx && this->miny == this->maxy && this->minz == this->maxz) {
		Vector3 R = Vector3(this->minx, this->maxy, this->minz);
		if (r > 0)
			R = rotate(R, get_center(minx, maxx, miny, maxy, minz, maxz), r);
		return R.x >= minx - d && R.x < maxx + d + 1.0 && R.y >= miny - d && R.y < maxy + d + 1.0 && R.z >= minz - d && R.z < maxz + d + 1.0 && is_unfiltered(filter_callback);
	}
	return minz >= this->minz - d && maxz < this->maxz + d + 1.0 && boxes_intersect(minx - d, maxx + d, miny - d, maxy + d, r, this->minx, this->maxx, this->miny, this->maxy, this->rotation) && is_unfiltered(filter_callback);
}

int map_frame::add_areas_for_point(std::vector<map_area*>& local_areas, float x, float y, float z, float d, int p, asIScriptFunction* filter_callback, asINT64 flags, asINT64 excluded_flags) {
	for (int i = 0; i < areas.size(); i++) {
		if (areas[i]->priority >= p && areas[i]->is_in_area(x, y, z, d, filter_callback, flags, excluded_flags)) {
			p = areas[i]->priority;
			local_areas.push_back(areas[i]);
		}
	}
	return p;
}
int map_frame::add_areas_for_range(std::vector<map_area*>& local_areas, float minx, float maxx, float miny, float maxy, float minz, float maxz, float d, int p, asIScriptFunction* filter_callback, asINT64 flags, asINT64 excluded_flags) {
	for (int i = 0; i < areas.size(); i++) {
		if (!areas[i]->tmp_adding_to_result && areas[i]->priority >= p && areas[i]->is_in_area_range(minx, maxx, miny, maxy, minz, maxz, d, 0, filter_callback, flags, excluded_flags)) {
			//p=areas[i]->priority; // Object can be reframed at the end of frame with lower priority than something that is higher in the frame, such item will not be included in list if p keeps getting reset.
			local_areas.push_back(areas[i]);
			areas[i]->tmp_adding_to_result = true;
		}
	}
	return p;
}
void map_frame::reset() {
	for (auto i : areas)
		i->release();
	areas.clear();
}

void coordinate_map::add_ref() {
	asAtomicInc(ref_count);
}
void coordinate_map::release() {
	if (asAtomicDec(ref_count) < 1) {
		reset();
		delete this;
	}
}
Vector3 coordinate_map::get_frame_coordinates(int x, int y, int z, int size) {
	Vector3 r;
	r.x = 0;
	r.y = 0;
	r.z = 0;
	if (size < 0 || size >= total_frame_sizes) return r;
	r.x -= x & (frame_sizes[size] - 1);
	r.y -= y & (frame_sizes[size] - 1);
	r.z -= z & (frame_sizes[size] - 1);
	return r;
}
map_frame* coordinate_map::get_frame(int x, int y, int z, int size, bool create) {
	if (size < 0 || size >= total_frame_sizes) return NULL;
	x -= x & (frame_sizes[size] - 1);
	y -= y & (frame_sizes[size] - 1);
	z -= z & (frame_sizes[size] - 1);
	auto it = frames[size].find(hashpoint(x, y, z));
	if (it == frames[size].end()) {
		if (!create) return NULL;
		map_frame* mf = new map_frame();
		mf->size = size;
		frames[size][hashpoint(x, y, z)] = mf;
		return mf;
	}
	return it->second;
}
map_area* coordinate_map::add_area(float minx, float maxx, float miny, float maxy, float minz, float maxz, float rotation, CScriptAny* primary_data, const std::string& data1, const std::string& data2, const std::string& data3, int priority, asINT64 flags) {
	return new map_area(this, minx, maxx, miny, maxy, minz, maxz, rotation, primary_data, data1, data2, data3, priority, flags);
}
void coordinate_map::get_areas(float minx, float maxx, float miny, float maxy, float minz, float maxz, float d, std::vector<map_area*>& local_areas, bool priority_check, asIScriptFunction* filter_callback, asINT64 flags, asINT64 excluded_flags) {
	int p = -1;
	if (minx == maxx && miny == maxy && minz == maxz && d < 1) {
		for (int i = total_frame_sizes - 1; i >= 0; i--) {
			map_frame* f = get_frame(minx, miny, minz, i, false);
			if (!f) continue;
			p = f->add_areas_for_point(local_areas, minx, miny, minz, d, p, filter_callback, flags, excluded_flags);
			if (!priority_check) p = -1;
		}
	} else {
		for (int i = total_frame_sizes - 1; i >= 0; i--) {
			for (int x = minx - d; x <= maxx + d + frame_sizes[i]; x += frame_sizes[i]) {
				for (int y = miny - d; y <= maxy + d + frame_sizes[i]; y += frame_sizes[i]) {
					for (int z = minz - d; z <= maxz + d + frame_sizes[i]; z += frame_sizes[i]) {
						map_frame* f = get_frame(x, y, z, i, false);
						if (!f) continue;
						p = f->add_areas_for_range(local_areas, minx, maxx, miny, maxy, minz, maxz, d, p, filter_callback, flags, excluded_flags);
						if (!priority_check) p = -1;
					}
				}
			}
		}
	}
	for (auto i : local_areas)
		i->tmp_adding_to_result = false;
	if (priority_check && local_areas.size() > 1) {
		map_area* final = NULL;
		for (auto i : local_areas) {
			if (!final || i->priority > final->priority) final = i;
		}
		if (final) std::swap(final, local_areas[local_areas.size() - 1]);
	} else if (local_areas.size() > 1)
		sort(local_areas.begin(), local_areas.end(), map_area_sort);
	if (filter_callback) filter_callback->Release();
}
CScriptArray* coordinate_map::get_areas_script(float x, float y, float z, float d, asIScriptFunction* filter_callback, asINT64 flags, asINT64 excluded_flags) {
	std::vector<map_area*> local_areas;
	local_areas.reserve(20);
	if (!g_MapAreaArrayType) g_MapAreaArrayType = g_ScriptEngine->GetTypeInfoByDecl("array<coordinate_map_area@>");
	CScriptArray* array = CScriptArray::Create(g_MapAreaArrayType);
	get_areas(x, x, y, y, z, z, d, local_areas, false, filter_callback, flags, excluded_flags);
	array->Reserve(local_areas.size());
	for (int i = 0; i < local_areas.size(); i++)
		array->InsertLast(&local_areas[i]);
	return array;
}
CScriptArray* coordinate_map::get_areas_in_range_script(float minx, float maxx, float miny, float maxy, float minz, float maxz, float d, asIScriptFunction* filter_callback, asINT64 flags, asINT64 excluded_flags) {
	std::vector<map_area*> local_areas;
	local_areas.reserve(20);
	if (!g_MapAreaArrayType) g_MapAreaArrayType = g_ScriptEngine->GetTypeInfoByDecl("array<coordinate_map_area@>");
	CScriptArray* array = CScriptArray::Create(g_MapAreaArrayType);
	get_areas(minx, maxx, miny, maxy, minz, maxz, d, local_areas, false, filter_callback, flags, excluded_flags);
	array->Reserve(local_areas.size());
	for (int i = 0; i < local_areas.size(); i++)
		array->InsertLast(&local_areas[i]);
	return array;
}
map_area* coordinate_map::get_area(float x, float y, float z, int max_priority, float d, asIScriptFunction* filter_callback, asINT64 flags, asINT64 excluded_flags) {
	std::vector<map_area*> local_areas;
	get_areas(x, x, y, y, z, z, d, local_areas, max_priority < 0, filter_callback, flags, excluded_flags);
	if (local_areas.size() < 1)return NULL;
	if (max_priority < 0) {
		local_areas[local_areas.size() - 1]->add_ref();
		return local_areas[local_areas.size() - 1];
	}
	for (int i = local_areas.size() - 1; i >= 0; i--) {
		if (local_areas[i]->priority >= max_priority) continue;
		local_areas[i]->add_ref();
		return local_areas[i];
	}
	return NULL;
}
void coordinate_map::reset() {
	for (int i = 0; i < total_frame_sizes; i++) {
		for (auto f : frames[i]) {
			f.second->reset();
			delete f.second;
		}
		frames[i].clear();
	}
}

coordinate_map* new_coordinate_map() {
	return new coordinate_map();
}

void RegisterScriptMap(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterGlobalFunction(_O("vector rotate(const vector&in point, const vector&in origin, double theta, bool maintain_z = true)"), asFUNCTION(rotate), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool boxes_intersect(float, float, float, float, float, float, float, float, float, float)"), asFUNCTION(boxes_intersect), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_MAP);
	engine->RegisterObjectType(_O("coordinate_map"), 0, asOBJ_REF);
	engine->RegisterObjectType(_O("coordinate_map_area"), 0, asOBJ_REF);
	engine->RegisterFuncdef(_O("bool coordinate_map_filter_callback(coordinate_map_area@)"));
	engine->RegisterObjectBehaviour(_O("coordinate_map_area"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(map_area, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("coordinate_map_area"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(map_area, release), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const coordinate_map@ map"), asOFFSET(map_area, parent));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float minx"), asOFFSET(map_area, minx));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float maxx"), asOFFSET(map_area, maxx));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float miny"), asOFFSET(map_area, miny));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float maxy"), asOFFSET(map_area, maxy));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float minz"), asOFFSET(map_area, minz));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float maxz"), asOFFSET(map_area, maxz));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const float rotation"), asOFFSET(map_area, rotation));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("any@ primary_data"), asOFFSET(map_area, primary_data));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const string data1"), asOFFSET(map_area, data1));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const string data2"), asOFFSET(map_area, data2));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const string data3"), asOFFSET(map_area, data3));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const int priority"), asOFFSET(map_area, priority));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("const bool framed"), asOFFSET(map_area, framed));
	engine->RegisterObjectProperty(_O("coordinate_map_area"), _O("int64 flags"), asOFFSET(map_area, flags));
	engine->RegisterObjectMethod(_O("coordinate_map_area"), _O("void unframe()"), asMETHOD(map_area, unframe), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map_area"), _O("void reframe()"), asMETHOD(map_area, reframe), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map_area"), _O("void set(float minx, float maxx, float miny, float maxy, float minz, float maxz, float theta)"), asMETHOD(map_area, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map_area"), _O("void set_area(float minx, float maxx, float miny, float maxy, float minz, float maxz)"), asMETHOD(map_area, set_area), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map_area"), _O("void set_rotation(float theta)"), asMETHOD(map_area, set_rotation), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map_area"), _O("bool is_in_area(float x, float y, float z, float d = 0.0, coordinate_map_filter_callback@ = null, int64 required_flags = 0, int64 excluded_flags = 0) const"), asMETHOD(map_area, is_in_area), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("coordinate_map"), asBEHAVE_FACTORY, _O("coordinate_map @m()"), asFUNCTION(new_coordinate_map), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("coordinate_map"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(coordinate_map, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("coordinate_map"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(coordinate_map, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map"), _O("coordinate_map_area@ add_area(float minx, float maxx, float miny, float maxy, float minz, float maxz, float rotation, any@ primary_data, const string&in data1, const string&in data2, const string&in data3, int priority, int64 flags = 0)"), asMETHOD(coordinate_map, add_area), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map"), _O("coordinate_map_area@[]@ get_areas(float x, float y, float z, float d = 0.0, coordinate_map_filter_callback@ = null, int64 required_flags = 0, int64 excluded_flags = 0) const"), asMETHOD(coordinate_map, get_areas_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map"), _O("coordinate_map_area@[]@ get_areas(float minx, float maxx, float miny, float maxy, float minz, float maxz, float d = 0.0, coordinate_map_filter_callback@ = null, int64 required_flags = 0, int64 excluded_flags = 0) const"), asMETHOD(coordinate_map, get_areas_in_range_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map"), _O("coordinate_map_area@ get_area(float x, float y, float z, int priority = -1, float d = 0.0, coordinate_map_filter_callback@ = null, int64 required_flags = 0, int64 excluded_flags = 0) const"), asMETHOD(coordinate_map, get_area), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("coordinate_map"), _O("void reset()"), asMETHOD(coordinate_map, reset), asCALL_THISCALL);
}
