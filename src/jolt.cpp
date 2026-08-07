/* jolt.cpp - JoltPhysics wrapper integration
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

#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>
#include <angelscript.h>
#include <scriptany.h>
#include <scriptarray.h>

#define JPH_OBJECT_STREAM
#define JPH_FLOATING_POINT_EXCEPTIONS_ENABLED
#include <Jolt/Jolt.h>
#include <Jolt/RegisterTypes.h>
#include <Jolt/Core/Factory.h>
#include <Jolt/Core/Memory.h>
#include <Jolt/Core/TempAllocator.h>
#include <Jolt/Core/JobSystemThreadPool.h>
#include <Jolt/Geometry/AABox.h>
#include <Jolt/Math/Vec3.h>
#include <Jolt/Math/Quat.h>
#include <Jolt/Math/Mat44.h>
#include <Jolt/Physics/PhysicsSettings.h>
#include <Jolt/Physics/PhysicsSystem.h>
#include <Jolt/Physics/Body/BodyCreationSettings.h>
#include <Jolt/Physics/Body/BodyActivationListener.h>
#include <Jolt/Physics/Body/BodyInterface.h>
#include <Jolt/Physics/Body/BodyID.h>
#include <Jolt/Physics/Body/MotionType.h>
#include <Jolt/Physics/Body/MotionQuality.h>
#include <Jolt/Physics/Collision/ContactListener.h>
#include <Jolt/Physics/Collision/Shape/Shape.h>
#include <Jolt/Physics/Collision/Shape/ConvexShape.h>
#include <Jolt/Physics/Collision/Shape/SphereShape.h>
#include <Jolt/Physics/Collision/Shape/BoxShape.h>
#include <Jolt/Physics/Collision/Shape/CapsuleShape.h>
#include <Jolt/Physics/Collision/NarrowPhaseQuery.h>
#include <Jolt/Physics/Collision/PhysicsMaterial.h>
#include <Jolt/Physics/Body/BodyLock.h>
#include <Jolt/Physics/Collision/RayCast.h>
#include <Jolt/Physics/Collision/CastResult.h>
#include <Jolt/Physics/Collision/BroadPhase/BroadPhaseLayer.h>

#include "nvgt.h"
#include "nvgt_angelscript.h"
#include "jolt.h"
#include "UI.h" // temp alert

using namespace JPH;
using namespace std;

// -- physics_material: ref-counted (via Jolt's RefTarget) override of PhysicsMaterial --
// Note: this Jolt version's PhysicsMaterial only provides debug info; friction/restitution are per-body via BodyInterface.
// We store friction/restitution here for game-logic use (e.g. reading back when adding a body to the world).
class nvgt_physics_material final : public PhysicsMaterial {
public:
	float friction;
	float restitution;
	string debug_name;
	IPLMaterial acoustic;
	nvgt_physics_material(float friction = 0.2f, float restitution = 0.0f, const string& name = "") : friction(friction), restitution(restitution), debug_name(name), acoustic{{0.10f,0.20f,0.30f}, 0.05f, {0.100f,0.050f,0.030f}} {}
	const char* GetDebugName() const override { return debug_name.c_str(); }
	void as_addref() { AddRef(); }
	void as_release() { Release(); }
};
static string& physics_material_get_name(nvgt_physics_material* m) { return m->debug_name; }
static void physics_material_set_name(nvgt_physics_material* m, const string& v) { m->debug_name = v; }

// Named acoustic material presets: {absorption[low,mid,high], scattering, transmission[low,mid,high]}.
static unordered_map<string, IPLMaterial> g_acoustic_presets = {
	{"generic",  {{0.10f,0.20f,0.30f}, 0.05f, {0.100f,0.050f,0.030f}}},
	{"brick",    {{0.03f,0.04f,0.07f}, 0.05f, {0.015f,0.015f,0.015f}}},
	{"concrete", {{0.05f,0.07f,0.08f}, 0.05f, {0.015f,0.002f,0.001f}}},
	{"ceramic",  {{0.01f,0.02f,0.02f}, 0.05f, {0.060f,0.044f,0.011f}}},
	{"gravel",   {{0.60f,0.70f,0.80f}, 0.05f, {0.031f,0.012f,0.008f}}},
	{"carpet",   {{0.24f,0.69f,0.73f}, 0.05f, {0.020f,0.005f,0.003f}}},
	{"glass",    {{0.06f,0.03f,0.02f}, 0.05f, {0.060f,0.044f,0.011f}}},
	{"plaster",  {{0.12f,0.06f,0.04f}, 0.05f, {0.056f,0.056f,0.004f}}},
	{"wood",     {{0.11f,0.07f,0.06f}, 0.05f, {0.070f,0.014f,0.005f}}},
	{"metal",    {{0.20f,0.07f,0.06f}, 0.05f, {0.200f,0.025f,0.010f}}},
	{"rock",     {{0.13f,0.20f,0.24f}, 0.05f, {0.015f,0.002f,0.001f}}},
	{"sand",     {{0.45f,0.65f,0.75f}, 0.90f, {0.010f,0.003f,0.002f}}},
	{"snow",     {{0.45f,0.75f,0.90f}, 0.60f, {0.008f,0.003f,0.001f}}},
	{"soil",     {{0.50f,0.60f,0.70f}, 0.80f, {0.012f,0.005f,0.002f}}},
	{"foliage",  {{0.30f,0.50f,0.70f}, 0.85f, {0.050f,0.030f,0.020f}}},
	{"water",    {{0.01f,0.01f,0.02f}, 0.10f, {0.001f,0.001f,0.001f}}},
};
static void physics_material_define_acoustics(const string& name, float abs_low, float abs_mid, float abs_high, float scattering, float trans_low, float trans_mid, float trans_high) {
	g_acoustic_presets[name] = {{abs_low, abs_mid, abs_high}, scattering, {trans_low, trans_mid, trans_high}};
}

// -- Object layer definitions --
// Layer 0: non-moving (static/terrain). Layer 1: moving (dynamic/kinematic).
// Up to 32 custom layers are supported; by default only 0 and 1 are defined.
namespace JoltLayers {
	static constexpr ObjectLayer NON_MOVING = 0;
	static constexpr ObjectLayer MOVING = 1;
	static constexpr uint NUM_LAYERS = 2;
}
namespace JoltBPLayers {
	static constexpr BroadPhaseLayer NON_MOVING(0);
	static constexpr BroadPhaseLayer MOVING(1);
	static constexpr uint NUM_LAYERS = 2;
}

class JoltBPLayerInterface final : public BroadPhaseLayerInterface {
	BroadPhaseLayer mObjToBP[JoltLayers::NUM_LAYERS];
public:
	JoltBPLayerInterface() {
		mObjToBP[JoltLayers::NON_MOVING] = JoltBPLayers::NON_MOVING;
		mObjToBP[JoltLayers::MOVING] = JoltBPLayers::MOVING;
	}
	uint GetNumBroadPhaseLayers() const override { return JoltBPLayers::NUM_LAYERS; }
	BroadPhaseLayer GetBroadPhaseLayer(ObjectLayer inLayer) const override {
		return inLayer < JoltLayers::NUM_LAYERS ? mObjToBP[inLayer] : JoltBPLayers::MOVING;
	}
#if defined(JPH_EXTERNAL_PROFILE) || defined(JPH_PROFILE_ENABLED)
	const char* GetBroadPhaseLayerName(BroadPhaseLayer inLayer) const override {
		return (BroadPhaseLayer::Type)inLayer == (BroadPhaseLayer::Type)JoltBPLayers::NON_MOVING ? "NON_MOVING" : "MOVING";
	}
#endif
};

class JoltObjVsBPFilter final : public ObjectVsBroadPhaseLayerFilter {
public:
	bool ShouldCollide(ObjectLayer inObj, BroadPhaseLayer inBP) const override {
		if (inObj == JoltLayers::NON_MOVING) return inBP == JoltBPLayers::MOVING;
		return true; // moving collides with everything
	}
};

class JoltObjLayerPairFilter final : public ObjectLayerPairFilter {
public:
	bool ShouldCollide(ObjectLayer inA, ObjectLayer inB) const override {
		if (inA == JoltLayers::NON_MOVING) return inB == JoltLayers::MOVING;
		return true;
	}
};

// -- AngelScript factory helpers --
template <class T>
void jolt_construct(void* mem) { new (mem) T(); }
template <class T, typename A1>
void jolt_construct1(void* mem, A1 a1) { new (mem) T(a1); }
template <class T, typename A1, typename A2>
void jolt_construct2(void* mem, A1 a1, A2 a2) { new (mem) T(a1, a2); }
template <class T>
void jolt_destruct(T* obj) { obj->~T(); }
template <class T>
void jolt_copy_construct(void* mem, const T& o) { new (mem) T(o); }

// Aligned heap allocation for any SIMD-aligned type (Vec3, AABox, …)
template<class T>
static inline void* scoped_alloc() { return JPH::AlignedAllocate(sizeof(T), alignof(T)); }

// new_vec3: the public factory used by subsystems and jolt.cpp internally
JPH::Vec3* new_vec3(float x, float y, float z) { return ::new (scoped_alloc<Vec3>()) Vec3(x, y, z); }

// Template: call a const member function on SelfT returning RetT by value, heap-allocating the result.
// Usage: scoped_ret<RetT, SelfT, &SelfT::Method, ExtraArgTypes...>
template<typename RetT, typename SelfT, auto MemberFn, typename... Args>
static RetT* scoped_ret(const SelfT* self, Args... args) { return ::new (scoped_alloc<RetT>()) RetT((self->*MemberFn)(args...)); }

// -- physics_transform: simple 7-float POD struct avoiding SIMD alignment issues --
struct physics_transform {
	float px = 0, py = 0, pz = 0;
	float qx = 0, qy = 0, qz = 0, qw = 1;

	physics_transform() = default;
	physics_transform(Vec3Arg pos, QuatArg rot) : px(pos.GetX()), py(pos.GetY()), pz(pos.GetZ()), qx(rot.GetX()), qy(rot.GetY()), qz(rot.GetZ()), qw(rot.GetW()) {}
	Vec3 GetPosition() const { return Vec3(px, py, pz); }
	Quat GetRotation() const { return Quat(qx, qy, qz, qw); }
	void SetPosition(Vec3Arg p) { px = p.GetX(); py = p.GetY(); pz = p.GetZ(); }
	void SetRotation(QuatArg r) { qx = r.GetX(); qy = r.GetY(); qz = r.GetZ(); qw = r.GetW(); }
	bool operator==(const physics_transform& o) const { return px==o.px && py==o.py && pz==o.pz && qx==o.qx && qy==o.qy && qz==o.qz && qw==o.qw; }
};

static void physics_transform_construct(void* mem) { new (mem) physics_transform(); }
static void physics_transform_construct_pq(void* mem, const Vec3& pos, const Quat& rot) { new (mem) physics_transform(pos, rot); }
static void physics_transform_destruct(physics_transform* t) { t->~physics_transform(); }

static Vec3* physics_transform_get_position(const physics_transform& t) { return new_vec3(t.GetPosition()); }
static void physics_transform_set_position(physics_transform& t, const Vec3& p) { t.SetPosition(p); }
static Quat physics_transform_get_rotation(const physics_transform& t) { return t.GetRotation(); }
static void physics_transform_set_rotation(physics_transform& t, const Quat& r) { t.SetRotation(r); }

// -- jolt_shape_ref: ref-counted wrapper around a Jolt Shape --
struct jolt_shape_ref {
	RefConst<Shape> shape;
	int refcount = 1;
	explicit jolt_shape_ref(RefConst<Shape> s) : shape(move(s)) {}
	void AddRef() { refcount++; }
	void Release() { if (--refcount <= 0) delete this; }
};

static jolt_shape_ref* jolt_sphere_shape_create(float radius, nvgt_physics_material* mat) {
	SphereShapeSettings settings(radius);
	if (mat) settings.mMaterial = mat;
	auto result = settings.Create();
	if (result.HasError()) return nullptr;
	return new jolt_shape_ref(result.Get());
}
static jolt_shape_ref* jolt_box_shape_create(const Vec3& half_extents, float convex_radius, nvgt_physics_material* mat) {
	BoxShapeSettings settings(half_extents, convex_radius);
	if (mat) settings.mMaterial = mat;
	auto result = settings.Create();
	if (result.HasError()) return nullptr;
	return new jolt_shape_ref(result.Get());
}
static jolt_shape_ref* jolt_capsule_shape_create(float half_height, float radius, nvgt_physics_material* mat) {
	CapsuleShapeSettings settings(half_height, radius);
	if (mat) settings.mMaterial = mat;
	auto result = settings.Create();
	if (result.HasError()) return nullptr;
	return new jolt_shape_ref(result.Get());
}
static uint8 jolt_shape_get_type(const jolt_shape_ref& s) { return (uint8)s.shape->GetType(); }
static uint8 jolt_shape_get_sub_type(const jolt_shape_ref& s) { return (uint8)s.shape->GetSubType(); }
static AABox* jolt_shape_get_local_bounds(const jolt_shape_ref& s) { return ::new (scoped_alloc<AABox>()) AABox(s.shape->GetLocalBounds()); }
static float jolt_shape_get_volume(const jolt_shape_ref& s) { return s.shape->GetVolume(); }

// -- Shape hierarchy cast helpers (all backed by jolt_shape_ref*; AS sees different types) --
// Explicit downcasts (may return null)
static jolt_shape_ref* jolt_shape_to_convex(jolt_shape_ref* s) {
	if (!s || s->shape->GetType() != EShapeType::Convex) return nullptr;
	s->AddRef(); return s;
}
static jolt_shape_ref* jolt_convex_to_sphere(jolt_shape_ref* s) {
	if (!s || s->shape->GetSubType() != EShapeSubType::Sphere) return nullptr;
	s->AddRef(); return s;
}
static jolt_shape_ref* jolt_convex_to_box(jolt_shape_ref* s) {
	if (!s || s->shape->GetSubType() != EShapeSubType::Box) return nullptr;
	s->AddRef(); return s;
}
static jolt_shape_ref* jolt_convex_to_capsule(jolt_shape_ref* s) {
	if (!s || s->shape->GetSubType() != EShapeSubType::Capsule) return nullptr;
	s->AddRef(); return s;
}
// Implicit upcasts (always succeed)
static jolt_shape_ref* jolt_shape_ref_upcast(jolt_shape_ref* s) { if (s) s->AddRef(); return s; }

// -- ConvexShape accessors --
static float jolt_convex_shape_get_density(const jolt_shape_ref* s) { return static_cast<const ConvexShape*>(s->shape.GetPtr())->GetDensity(); }
static void jolt_convex_shape_set_density(jolt_shape_ref* s, float density) { const_cast<ConvexShape*>(static_cast<const ConvexShape*>(s->shape.GetPtr()))->SetDensity(density); }
static nvgt_physics_material* jolt_convex_shape_get_material(const jolt_shape_ref* s) {
	const ConvexShape* cs = static_cast<const ConvexShape*>(s->shape.GetPtr());
	auto* mat = const_cast<nvgt_physics_material*>(dynamic_cast<const nvgt_physics_material*>(cs->GetMaterial()));
	if (mat) mat->AddRef();
	return mat;
}

// -- SphereShape specific --
static float jolt_sphere_shape_get_radius(const jolt_shape_ref* s) { return static_cast<const SphereShape*>(s->shape.GetPtr())->GetRadius(); }

// -- BoxShape specific --
static Vec3* jolt_box_shape_get_half_extent(const jolt_shape_ref* s) { return new_vec3(static_cast<const BoxShape*>(s->shape.GetPtr())->GetHalfExtent()); }
static float jolt_box_shape_get_convex_radius(const jolt_shape_ref* s) { return static_cast<const BoxShape*>(s->shape.GetPtr())->GetConvexRadius(); }

// -- CapsuleShape specific --
static float jolt_capsule_shape_get_half_height(const jolt_shape_ref* s) { return static_cast<const CapsuleShape*>(s->shape.GetPtr())->GetHalfHeightOfCylinder(); }
static float jolt_capsule_shape_get_radius(const jolt_shape_ref* s) { return static_cast<const CapsuleShape*>(s->shape.GetPtr())->GetRadius(); }

// -- Vec3 (vector) factory/release/assign for scoped reference type --
static Vec3* vec3_factory_default() { return new_vec3(0.0f, 0.0f, 0.0f); }
static Vec3* vec3_factory_xyz(float x, float y, float z) { return new_vec3(x, y, z); }
static Vec3* vec3_factory_copy(const Vec3& o) { return new_vec3(o); }
static void vec3_release(Vec3* v) { v->~Vec3(); JPH::AlignedFree(v); }
static Vec3& vec3_opAssign(Vec3& self, const Vec3& other) { self = other; return self; }
static float vec3_dot(const Vec3& self, const Vec3& other) { return self.Dot(other); }
static Vec3& vec3_add_assign(Vec3& self, const Vec3& other) { return self += other; }
static Vec3& vec3_sub_assign(Vec3& self, const Vec3& other) { return self -= other; }
static Vec3& vec3_mul_assign(Vec3& self, float s) { return self *= s; }
static Vec3& vec3_div_assign(Vec3& self, float s) { return self /= s; }
static bool vec3_equals(const Vec3& self, const Vec3& other) { return self == other; }
static Vec3* vec3_opAdd(const Vec3& self, const Vec3& other) { return new_vec3(self + other); }
static Vec3* vec3_opSub(const Vec3& self, const Vec3& other) { return new_vec3(self - other); }
static Vec3* vec3_opMul_v(const Vec3& self, const Vec3& other) { return new_vec3(self * other); }
static Vec3* vec3_opMul_f(const Vec3& self, float s) { return new_vec3(self * s); }
static Vec3* vec3_opDiv_f(const Vec3& self, float s) { return new_vec3(self / s); }
static Vec3* vec3_opNeg(const Vec3& self) { return new_vec3(-self); }
static Vec3* vec3_cross(const Vec3& self, const Vec3& other) { return new_vec3(self.Cross(other)); }
static string vec3_to_string(const Vec3& v) { return "vector(" + to_string(v.GetX()) + ", " + to_string(v.GetY()) + ", " + to_string(v.GetZ()) + ")"; }
static Vec3* vec3_sZero() { return new_vec3(Vec3::sZero()); }
static Vec3* vec3_sOne() { return new_vec3(Vec3::sOne()); }
static Vec3* vec3_sAxisX() { return new_vec3(Vec3::sAxisX()); }
static Vec3* vec3_sAxisY() { return new_vec3(Vec3::sAxisY()); }
static Vec3* vec3_sAxisZ() { return new_vec3(Vec3::sAxisZ()); }

// -- global math helpers (backward compat) --
static int nvgt_clamp_int(int v, int lo, int hi) { return v < lo ? lo : (v > hi ? hi : v); }
static float nvgt_clamp_float(float v, float lo, float hi) { return v < lo ? lo : (v > hi ? hi : v); }

// -- AABox additional wrappers --
static void aabb_inflate(AABox& b, float x, float y, float z) { Vec3 e(x, y, z); b.mMin -= e; b.mMax += e; }

// -- Quat wrappers --
static void quat_default_construct(void* mem) { new (mem) Quat(Quat::sIdentity()); }
static void quat_xyzw_construct(void* mem, float x, float y, float z, float w) { new (mem) Quat(x, y, z, w); }
static void quat_copy_construct(void* mem, const Quat& o) { new (mem) Quat(o); }
static Vec3* quat_mul_vec3(const Quat& q, const Vec3& v) { return new_vec3(q * v); }
static Quat quaternion_from_axis_angle(const Vec3& axis, float angle) { return Quat::sRotation(axis.Normalized(), angle); }
static Quat quaternion_from_euler_angles(const Vec3& angles) { return Quat::sEulerAngles(angles); }
static physics_transform jolt_identity_transform() { return physics_transform(); }
static string quat_to_string(const Quat& q) {
	return "quaternion(" + to_string(q.GetX()) + ", " + to_string(q.GetY()) + ", " + to_string(q.GetZ()) + ", " + to_string(q.GetW()) + ")";
}

// -- AABox factory/release for scoped reference type (ensures 16-byte SIMD alignment) --
static AABox* aabb_factory_default() { return ::new (scoped_alloc<AABox>()) AABox(); }
static AABox* aabb_factory_minmax(const Vec3& mn, const Vec3& mx) { return ::new (scoped_alloc<AABox>()) AABox(mn, mx); }
static AABox* aabb_factory_center_radius(const Vec3& center, float radius) { return ::new (scoped_alloc<AABox>()) AABox(center, radius); }
static AABox* aabb_factory_copy(const AABox* o) { return ::new (scoped_alloc<AABox>()) AABox(*o); }
static void aabb_release(AABox* b) { b->~AABox(); JPH::AlignedFree(b); }
static AABox& aabb_opAssign(AABox* self, const AABox& other) { *self = other; return *self; }
static Vec3* aabb_get_min(const AABox& b) { return new_vec3(b.mMin); }
static Vec3* aabb_get_max(const AABox& b) { return new_vec3(b.mMax); }
static void aabb_set_min(AABox& b, const Vec3& v) { b.mMin = v; }
static void aabb_set_max(AABox& b, const Vec3& v) { b.mMax = v; }
static bool aabb_contains_point(const AABox& b, const Vec3& p) { return b.Contains(p); }
static void aabb_encapsulate_point(AABox& b, const Vec3& p) { b.Encapsulate(p); }

// -- BodyID as a value type --
static void body_id_default_construct(void* mem) { new (mem) BodyID(); }
static void body_id_uint_construct(void* mem, uint32 id) { new (mem) BodyID(id); }
static void body_id_copy_construct(void* mem, const BodyID& o) { new (mem) BodyID(o); }
static string body_id_to_string(const BodyID& b) {
	if (b.IsInvalid()) return "jolt_body_id(invalid)";
	return "jolt_body_id(" + to_string(b.GetIndex()) + ":" + to_string(b.GetSequenceNumber()) + ")";
}

// -- Contact events queued from worker threads --
// world_normal is stored as plain floats to avoid SIMD alignment issues in std::vector
struct jolt_contact_event {
	enum Type : int { Added = 0, Persisted = 1, Removed = 2 };
	Type type;
	BodyID body1, body2;
	float nx = 0, ny = 0, nz = 0;
	float penetration_depth;
};

// -- forward declaration --
struct jolt_physics_world;

class jolt_contact_listener : public ContactListener {
public:
	jolt_physics_world* world = nullptr;
	mutex events_mutex;
	vector<jolt_contact_event> pending;

	void OnContactAdded(const Body& b1, const Body& b2, const ContactManifold& m, ContactSettings&) override {
		lock_guard<mutex> lk(events_mutex);
		const Vec3 n = m.mWorldSpaceNormal;
		pending.push_back({ jolt_contact_event::Added, b1.GetID(), b2.GetID(), n.GetX(), n.GetY(), n.GetZ(), m.mPenetrationDepth });
	}
	void OnContactPersisted(const Body& b1, const Body& b2, const ContactManifold& m, ContactSettings&) override {
		lock_guard<mutex> lk(events_mutex);
		const Vec3 n = m.mWorldSpaceNormal;
		pending.push_back({ jolt_contact_event::Persisted, b1.GetID(), b2.GetID(), n.GetX(), n.GetY(), n.GetZ(), m.mPenetrationDepth });
	}
	void OnContactRemoved(const SubShapeIDPair& pair) override {
		lock_guard<mutex> lk(events_mutex);
		pending.push_back({ jolt_contact_event::Removed, pair.GetBody1ID(), pair.GetBody2ID(), 0.0f, 0.0f, 0.0f, 0.0f });
	}
};

// -- Physics world wrapper --
struct jolt_physics_world {
	int refcount = 1;
	TempAllocatorImpl* temp_alloc;
	JobSystemThreadPool* job_system;
	JoltBPLayerInterface bp_layer_iface;
	JoltObjVsBPFilter obj_vs_bp_filter;
	JoltObjLayerPairFilter obj_layer_pair_filter;
	PhysicsSystem system;
	jolt_contact_listener contact_listener;
	asIScriptFunction* cb_contact_added = nullptr;
	asIScriptFunction* cb_contact_persisted = nullptr;
	asIScriptFunction* cb_contact_removed = nullptr;
	mutex user_data_mutex;
	unordered_map<uint32, CScriptAny*> user_data; // keyed by BodyID raw value

	jolt_physics_world(uint max_bodies, uint max_body_pairs, uint max_contact_constraints) {
		const uint temp_alloc_size = 10 * 1024 * 1024;
		temp_alloc = new TempAllocatorImpl(temp_alloc_size);
		int num_threads = max(1, (int)thread::hardware_concurrency() - 1);
		job_system = new JobSystemThreadPool(cMaxPhysicsJobs, cMaxPhysicsBarriers, num_threads);
		system.Init(max_bodies, 0, max_body_pairs, max_contact_constraints, bp_layer_iface, obj_vs_bp_filter, obj_layer_pair_filter);
		contact_listener.world = this;
		system.SetContactListener(&contact_listener);
	}
	~jolt_physics_world() {
		if (cb_contact_added) { cb_contact_added->Release(); cb_contact_added = nullptr; }
		if (cb_contact_persisted) { cb_contact_persisted->Release(); cb_contact_persisted = nullptr; }
		if (cb_contact_removed) { cb_contact_removed->Release(); cb_contact_removed = nullptr; }
		for (auto& [id, any] : user_data) if (any) any->Release();
		delete job_system;
		delete temp_alloc;
	}
	void AddRef() { refcount++; }
	void Release() { if (--refcount <= 0) delete this; }
};

static jolt_physics_world* jolt_world_factory(uint max_bodies, uint max_body_pairs, uint max_contact_constraints) {
	return new jolt_physics_world(max_bodies, max_body_pairs, max_contact_constraints);
}

// -- Dispatch a queued contact event to script --
static void dispatch_contact_event(asIScriptFunction* cb, const jolt_contact_event& ev) {
	if (!cb) return;
	asIScriptContext* ctx = asGetActiveContext();
	bool new_ctx = !ctx || ctx->PushState() < 0;
	if (new_ctx) ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return;
	if (ctx->Prepare(cb) < 0) { if (new_ctx) g_ScriptEngine->ReturnContext(ctx); else ctx->PopState(); return; }
	ctx->SetArgObject(0, (void*)&ev.body1);
	ctx->SetArgObject(1, (void*)&ev.body2);
	if (ev.type != jolt_contact_event::Removed) {
		Vec3 normal(ev.nx, ev.ny, ev.nz);
		ctx->SetArgObject(2, &normal);
		ctx->SetArgFloat(3, ev.penetration_depth);
	}
	ctx->Execute();
	if (new_ctx) g_ScriptEngine->ReturnContext(ctx); else ctx->PopState();
}

static void jolt_world_update(jolt_physics_world* w, float delta_time, int steps) {
	w->system.Update(delta_time, steps, w->temp_alloc, w->job_system);
	// Dispatch queued contact events on the main thread
	vector<jolt_contact_event> events;
	{ lock_guard<mutex> lk(w->contact_listener.events_mutex); events.swap(w->contact_listener.pending); }
	for (const auto& ev : events) {
		if (ev.type == jolt_contact_event::Added) dispatch_contact_event(w->cb_contact_added, ev);
		else if (ev.type == jolt_contact_event::Persisted) dispatch_contact_event(w->cb_contact_persisted, ev);
		else dispatch_contact_event(w->cb_contact_removed, ev);
	}
}

static void jolt_world_set_contact_listener(jolt_physics_world* w, asIScriptFunction* on_added, asIScriptFunction* on_persisted, asIScriptFunction* on_removed) {
	if (w->cb_contact_added) w->cb_contact_added->Release();
	if (w->cb_contact_persisted) w->cb_contact_persisted->Release();
	if (w->cb_contact_removed) w->cb_contact_removed->Release();
	w->cb_contact_added = on_added;
	w->cb_contact_persisted = on_persisted;
	w->cb_contact_removed = on_removed;
}

static BodyID jolt_world_create_and_add_body(jolt_physics_world* w, jolt_shape_ref* shape, const Vec3& pos, const Quat& rot, int motion_type, uint16 layer, int activation) {
	if (!shape || !shape->shape) return BodyID();
	BodyCreationSettings settings(shape->shape.GetPtr(), pos, rot, (EMotionType)motion_type, (ObjectLayer)layer);
	return w->system.GetBodyInterface().CreateAndAddBody(settings, (EActivation)activation);
}

static void jolt_world_remove_body(jolt_physics_world* w, const BodyID& id) {
	w->system.GetBodyInterface().RemoveBody(id);
}

static void jolt_world_destroy_body(jolt_physics_world* w, const BodyID& id) {
	{ lock_guard<mutex> lk(w->user_data_mutex); auto it = w->user_data.find(id.GetIndexAndSequenceNumber()); if (it != w->user_data.end()) { if (it->second) it->second->Release(); w->user_data.erase(it); } }
	w->system.GetBodyInterface().DestroyBody(id);
}

static void jolt_world_remove_and_destroy_body(jolt_physics_world* w, const BodyID& id) {
	jolt_world_remove_body(w, id);
	jolt_world_destroy_body(w, id);
}

static void jolt_world_optimize_broadphase(jolt_physics_world* w) { w->system.OptimizeBroadPhase(); }
static Vec3* jolt_world_get_gravity(jolt_physics_world* w) { return new_vec3(w->system.GetGravity()); }
static void jolt_world_set_gravity(jolt_physics_world* w, const Vec3& g) { w->system.SetGravity(g); }
static uint jolt_world_get_num_bodies(jolt_physics_world* w) { return w->system.GetNumBodies(); }
static uint jolt_world_get_num_active_bodies(jolt_physics_world* w) { return w->system.GetNumActiveBodies(EBodyType::RigidBody); }
static bool jolt_world_were_bodies_in_contact(jolt_physics_world* w, const BodyID& a, const BodyID& b) { return w->system.WereBodiesInContact(a, b); }

// Position/rotation
static Vec3* jolt_world_get_position(jolt_physics_world* w, const BodyID& id) { return new_vec3(w->system.GetBodyInterface().GetPosition(id)); }
static void jolt_world_set_position(jolt_physics_world* w, const BodyID& id, const Vec3& pos, int activation) { w->system.GetBodyInterface().SetPosition(id, pos, (EActivation)activation); }
static Quat jolt_world_get_rotation(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().GetRotation(id); }
static void jolt_world_set_rotation(jolt_physics_world* w, const BodyID& id, const Quat& rot, int activation) { w->system.GetBodyInterface().SetRotation(id, rot, (EActivation)activation); }
static void jolt_world_set_position_and_rotation(jolt_physics_world* w, const BodyID& id, const Vec3& pos, const Quat& rot, int activation) { w->system.GetBodyInterface().SetPositionAndRotation(id, pos, rot, (EActivation)activation); }
static Vec3* jolt_world_get_center_of_mass_position(jolt_physics_world* w, const BodyID& id) { return new_vec3(w->system.GetBodyInterface().GetCenterOfMassPosition(id)); }
static physics_transform jolt_world_get_transform(jolt_physics_world* w, const BodyID& id) {
	RVec3 pos; Quat rot;
	w->system.GetBodyInterface().GetPositionAndRotation(id, pos, rot);
	return physics_transform(pos, rot);
}

// Velocity
static Vec3* jolt_world_get_linear_velocity(jolt_physics_world* w, const BodyID& id) { return new_vec3(w->system.GetBodyInterface().GetLinearVelocity(id)); }
static void jolt_world_set_linear_velocity(jolt_physics_world* w, const BodyID& id, const Vec3& v) { w->system.GetBodyInterface().SetLinearVelocity(id, v); }
static Vec3* jolt_world_get_angular_velocity(jolt_physics_world* w, const BodyID& id) { return new_vec3(w->system.GetBodyInterface().GetAngularVelocity(id)); }
static void jolt_world_set_angular_velocity(jolt_physics_world* w, const BodyID& id, const Vec3& v) { w->system.GetBodyInterface().SetAngularVelocity(id, v); }
static void jolt_world_add_linear_velocity(jolt_physics_world* w, const BodyID& id, const Vec3& v) { w->system.GetBodyInterface().AddLinearVelocity(id, v); }

// Forces / impulses
static void jolt_world_add_force(jolt_physics_world* w, const BodyID& id, const Vec3& force) { w->system.GetBodyInterface().AddForce(id, force); }
static void jolt_world_add_force_at(jolt_physics_world* w, const BodyID& id, const Vec3& force, const Vec3& point) { w->system.GetBodyInterface().AddForce(id, force, point); }
static void jolt_world_add_torque(jolt_physics_world* w, const BodyID& id, const Vec3& torque) { w->system.GetBodyInterface().AddTorque(id, torque); }
static void jolt_world_add_impulse(jolt_physics_world* w, const BodyID& id, const Vec3& impulse) { w->system.GetBodyInterface().AddImpulse(id, impulse); }
static void jolt_world_add_impulse_at(jolt_physics_world* w, const BodyID& id, const Vec3& impulse, const Vec3& point) { w->system.GetBodyInterface().AddImpulse(id, impulse, point); }
static void jolt_world_add_angular_impulse(jolt_physics_world* w, const BodyID& id, const Vec3& impulse) { w->system.GetBodyInterface().AddAngularImpulse(id, impulse); }

// Activation
static void jolt_world_activate_body(jolt_physics_world* w, const BodyID& id) { w->system.GetBodyInterface().ActivateBody(id); }
static void jolt_world_deactivate_body(jolt_physics_world* w, const BodyID& id) { w->system.GetBodyInterface().DeactivateBody(id); }
static bool jolt_world_is_active(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().IsActive(id); }
static bool jolt_world_is_added(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().IsAdded(id); }

// Motion type
static void jolt_world_set_motion_type(jolt_physics_world* w, const BodyID& id, int motion_type, int activation) { w->system.GetBodyInterface().SetMotionType(id, (EMotionType)motion_type, (EActivation)activation); }
static int jolt_world_get_motion_type(jolt_physics_world* w, const BodyID& id) { return (int)w->system.GetBodyInterface().GetMotionType(id); }

// Shape
static void jolt_world_set_shape(jolt_physics_world* w, const BodyID& id, jolt_shape_ref* shape, bool update_mass, int activation) {
	if (!shape || !shape->shape) return;
	w->system.GetBodyInterface().SetShape(id, shape->shape.GetPtr(), update_mass, (EActivation)activation);
}

// User data
static void jolt_world_set_user_data(jolt_physics_world* w, const BodyID& id, CScriptAny* any) {
	lock_guard<mutex> lk(w->user_data_mutex);
	uint32 key = id.GetIndexAndSequenceNumber();
	auto it = w->user_data.find(key);
	if (it != w->user_data.end() && it->second) it->second->Release();
	if (any) { any->AddRef(); w->user_data[key] = any; } else { w->user_data.erase(key); }
}
static CScriptAny* jolt_world_get_user_data(jolt_physics_world* w, const BodyID& id) {
	lock_guard<mutex> lk(w->user_data_mutex);
	auto it = w->user_data.find(id.GetIndexAndSequenceNumber());
	if (it == w->user_data.end() || !it->second) return nullptr;
	it->second->AddRef();
	return it->second;
}

// Kinematic move
static void jolt_world_move_kinematic(jolt_physics_world* w, const BodyID& id, const Vec3& target_pos, const Quat& target_rot, float delta_time) {
	w->system.GetBodyInterface().MoveKinematic(id, target_pos, target_rot, delta_time);
}

// Raycast: returns true if hit, fills out_body_id and out_fraction
static bool jolt_world_cast_ray(jolt_physics_world* w, const Vec3& origin, const Vec3& direction, BodyID& out_body, float& out_fraction) {
	RRayCast ray(origin, direction);
	RayCastResult result;
	if (w->system.GetNarrowPhaseQuery().CastRay(ray, result)) {
		out_body = result.mBodyID;
		out_fraction = result.mFraction;
		return true;
	}
	return false;
}

// -- physics_material factory and accessors --
static nvgt_physics_material* physics_material_create(float friction, float restitution, const string& name) {
	auto* m = new nvgt_physics_material(friction, restitution, name);
	m->AddRef();
	auto it = g_acoustic_presets.find(name);
	if (it != g_acoustic_presets.end()) m->acoustic = it->second;
	return m;
}

// -- Body interface: material properties --
static float jolt_world_get_friction(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().GetFriction(id); }
static void jolt_world_set_friction(jolt_physics_world* w, const BodyID& id, float v) { w->system.GetBodyInterface().SetFriction(id, v); }
static float jolt_world_get_restitution(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().GetRestitution(id); }
static void jolt_world_set_restitution(jolt_physics_world* w, const BodyID& id, float v) { w->system.GetBodyInterface().SetRestitution(id, v); }
static float jolt_world_get_gravity_factor(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().GetGravityFactor(id); }
static void jolt_world_set_gravity_factor(jolt_physics_world* w, const BodyID& id, float v) { w->system.GetBodyInterface().SetGravityFactor(id, v); }

// -- Body interface: spatial queries --
static AABox* jolt_world_get_world_space_bounds(jolt_physics_world* w, const BodyID& id) {
	BodyLockRead lock(w->system.GetBodyLockInterface(), id);
	if (!lock.Succeeded()) return ::new (scoped_alloc<AABox>()) AABox();
	return ::new (scoped_alloc<AABox>()) AABox(lock.GetBody().GetWorldSpaceBounds());
}

// -- Body interface: velocity limits --
static float jolt_world_get_max_linear_velocity(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().GetMaxLinearVelocity(id); }
static void jolt_world_set_max_linear_velocity(jolt_physics_world* w, const BodyID& id, float v) { w->system.GetBodyInterface().SetMaxLinearVelocity(id, v); }
static float jolt_world_get_max_angular_velocity(jolt_physics_world* w, const BodyID& id) { return w->system.GetBodyInterface().GetMaxAngularVelocity(id); }
static void jolt_world_set_max_angular_velocity(jolt_physics_world* w, const BodyID& id, float v) { w->system.GetBodyInterface().SetMaxAngularVelocity(id, v); }

// -- Body interface: buoyancy --
static bool jolt_world_apply_buoyancy_impulse(jolt_physics_world* w, const BodyID& id, const Vec3& surface_pos, const Vec3& surface_normal, float buoyancy, float linear_drag, float angular_drag, const Vec3& fluid_velocity, const Vec3& gravity, float delta_time) {
	return w->system.GetBodyInterface().ApplyBuoyancyImpulse(id, surface_pos, surface_normal, buoyancy, linear_drag, angular_drag, fluid_velocity, gravity, delta_time);
}

// -- Global Jolt initialization (called once) --
static bool g_jolt_initialized = false;
static void jolt_ensure_init() {
	if (g_jolt_initialized) return;
	g_jolt_initialized = true;
	RegisterDefaultAllocator();
	Factory::sInstance = new Factory();
	RegisterTypes();
}

// -- Steam Audio custom scene callbacks --

// Helper: cast one ray and fill hit. query and lock_iface must already be retrieved from the world.
static void jolt_ipl_trace_ray(const NarrowPhaseQuery& query, const BodyLockInterface& lock_iface, const IPLRay& ipl_ray, IPLfloat32 min_dist, IPLfloat32 max_dist, IPLHit& hit) {
	hit.distance = INFINITY;
	hit.triangleIndex = -1;
	hit.objectIndex = -1;
	hit.materialIndex = -1;
	hit.normal = {0.0f, 0.0f, 0.0f};
	hit.material = nullptr;
	if (max_dist <= min_dist) return;
	Vec3 origin(ipl_ray.origin.x, ipl_ray.origin.y, ipl_ray.origin.z);
	Vec3 dir(ipl_ray.direction.x, ipl_ray.direction.y, ipl_ray.direction.z);
	RRayCast jolt_ray{origin, dir * max_dist};
	RayCastResult result;
	if (!query.CastRay(jolt_ray, result)) return;
	float hit_dist = result.mFraction * max_dist;
	if (hit_dist < min_dist) return;
	hit.distance = hit_dist;
	BodyLockRead lock(lock_iface, result.mBodyID);
	if (!lock.Succeeded()) return;
	const Body& body = lock.GetBody();
	RVec3 world_hit = jolt_ray.GetPointOnRay(result.mFraction);
	Vec3 normal = body.GetWorldSpaceSurfaceNormal(result.mSubShapeID2, world_hit);
	hit.normal = {normal.GetX(), normal.GetY(), normal.GetZ()};
	if (const auto* cs = dynamic_cast<const ConvexShape*>(body.GetShape())) {
		if (const auto* mat = dynamic_cast<const nvgt_physics_material*>(cs->GetMaterial())) {
			hit.material = const_cast<IPLMaterial*>(&mat->acoustic);
			hit.materialIndex = 0;
		}
	}
}

void IPLCALL jolt_ipl_closest_hit(const IPLRay* ray, IPLfloat32 min_dist, IPLfloat32 max_dist, IPLHit* hit, void* user_data) {
	auto* world = static_cast<jolt_physics_world*>(user_data);
	jolt_ipl_trace_ray(world->system.GetNarrowPhaseQuery(), world->system.GetBodyLockInterface(), *ray, min_dist, max_dist, *hit);
}

void IPLCALL jolt_ipl_any_hit(const IPLRay* ray, IPLfloat32 min_dist, IPLfloat32 max_dist, IPLuint8* occluded, void* user_data) {
	auto* world = static_cast<jolt_physics_world*>(user_data);
	if (max_dist <= min_dist) { *occluded = 1; return; }
	Vec3 origin(ray->origin.x, ray->origin.y, ray->origin.z);
	Vec3 dir(ray->direction.x, ray->direction.y, ray->direction.z);
	RRayCast jolt_ray{origin, dir * max_dist};
	RayCastResult result;
	bool hit = world->system.GetNarrowPhaseQuery().CastRay(jolt_ray, result);
	*occluded = (hit && result.mFraction * max_dist >= min_dist) ? 1 : 0;
}

void IPLCALL jolt_ipl_batched_closest_hit(IPLint32 num_rays, const IPLRay* rays, const IPLfloat32* min_dists, const IPLfloat32* max_dists, IPLHit* hits, void* user_data) {
	auto* world = static_cast<jolt_physics_world*>(user_data);
	const NarrowPhaseQuery& query = world->system.GetNarrowPhaseQuery();
	const BodyLockInterface& lock_iface = world->system.GetBodyLockInterface();
	for (IPLint32 i = 0; i < num_rays; i++)
		jolt_ipl_trace_ray(query, lock_iface, rays[i], min_dists[i], max_dists[i], hits[i]);
}

void IPLCALL jolt_ipl_batched_any_hit(IPLint32 num_rays, const IPLRay* rays, const IPLfloat32* min_dists, const IPLfloat32* max_dists, IPLuint8* occluded, void* user_data) {
	auto* world = static_cast<jolt_physics_world*>(user_data);
	const NarrowPhaseQuery& query = world->system.GetNarrowPhaseQuery();
	for (IPLint32 i = 0; i < num_rays; i++) {
		if (max_dists[i] <= min_dists[i]) { occluded[i] = 1; continue; }
		Vec3 origin(rays[i].origin.x, rays[i].origin.y, rays[i].origin.z);
		Vec3 dir(rays[i].direction.x, rays[i].direction.y, rays[i].direction.z);
		RRayCast jolt_ray{origin, dir * max_dists[i]};
		RayCastResult result;
		bool hit = query.CastRay(jolt_ray, result);
		occluded[i] = (hit && result.mFraction * max_dists[i] >= min_dists[i]) ? 1 : 0;
	}
}

// -- Registration --

static void RegisterJoltMaterial(asIScriptEngine* engine) {
	engine->RegisterObjectType("physics_material", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_material", asBEHAVE_ADDREF, "void f()", asMETHOD(nvgt_physics_material, as_addref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_material", asBEHAVE_RELEASE, "void f()", asMETHOD(nvgt_physics_material, as_release), asCALL_THISCALL);
	engine->RegisterObjectProperty("physics_material", "float friction", asOFFSET(nvgt_physics_material, friction));
	engine->RegisterObjectProperty("physics_material", "float restitution", asOFFSET(nvgt_physics_material, restitution));
	engine->RegisterObjectMethod("physics_material", "string get_name() const property", asFUNCTION(physics_material_get_name), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_material", "void set_name(const string&in) property", asFUNCTION(physics_material_set_name), asCALL_CDECL_OBJFIRST);
	// Acoustic properties (Steam Audio IPLMaterial fields exposed as individual named properties).
	// absorption: fraction of sound absorbed at low (400Hz), mid (2.5kHz), high (15kHz) frequencies.
	// scattering: 0 = pure specular reflection, 1 = pure diffuse.
	// transmission: fraction of sound transmitted through at low, mid, high frequencies.
	int ab = asOFFSET(nvgt_physics_material, acoustic);
	engine->RegisterObjectProperty("physics_material", "float acoustic_absorption_low",   ab + 0 * (int)sizeof(float));
	engine->RegisterObjectProperty("physics_material", "float acoustic_absorption_mid",   ab + 1 * (int)sizeof(float));
	engine->RegisterObjectProperty("physics_material", "float acoustic_absorption_high",  ab + 2 * (int)sizeof(float));
	engine->RegisterObjectProperty("physics_material", "float acoustic_scattering",       ab + 3 * (int)sizeof(float));
	engine->RegisterObjectProperty("physics_material", "float acoustic_transmission_low", ab + 4 * (int)sizeof(float));
	engine->RegisterObjectProperty("physics_material", "float acoustic_transmission_mid", ab + 5 * (int)sizeof(float));
	engine->RegisterObjectProperty("physics_material", "float acoustic_transmission_high",ab + 6 * (int)sizeof(float));
	engine->RegisterGlobalFunction("physics_material@ physics_material_create(float friction = 0.2f, float restitution = 0.0f, const string&in name = \"\")", asFUNCTION(physics_material_create), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_material_define_acoustics(const string&in name, float abs_low, float abs_mid, float abs_high, float scattering, float trans_low, float trans_mid, float trans_high)", asFUNCTION(physics_material_define_acoustics), asCALL_CDECL);
}

static void RegisterJoltMathTypes(asIScriptEngine* engine) {
	// vector (JPH::Vec3 - 16-byte SIMD aligned; registered as scoped reference type to guarantee alignment)
	engine->RegisterObjectType("vector", 0, asOBJ_REF | asOBJ_SCOPED);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_FACTORY, "vector@ f()", asFUNCTION(vec3_factory_default), asCALL_CDECL);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_FACTORY, "vector@ f(float x, float y, float z = 0.0f)", asFUNCTION(vec3_factory_xyz), asCALL_CDECL);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_FACTORY, "vector@ f(const vector&in)", asFUNCTION(vec3_factory_copy), asCALL_CDECL);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_RELEASE, "void f()", asFUNCTION(vec3_release), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector& opAssign(const vector&in)", asFUNCTION(vec3_opAssign), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "float get_x() const property", asMETHOD(Vec3, GetX), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float get_y() const property", asMETHOD(Vec3, GetY), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float get_z() const property", asMETHOD(Vec3, GetZ), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void set_x(float) property", asMETHOD(Vec3, SetX), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void set_y(float) property", asMETHOD(Vec3, SetY), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void set_z(float) property", asMETHOD(Vec3, SetZ), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void set(float x, float y, float z)", asMETHOD(Vec3, Set), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector@ opAdd(const vector&in) const", asFUNCTION(vec3_opAdd), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector@ opSub(const vector&in) const", asFUNCTION(vec3_opSub), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector@ opMul(const vector&in) const", asFUNCTION(vec3_opMul_v), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector@ opMul(float) const", asFUNCTION(vec3_opMul_f), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector@ opDiv(float) const", asFUNCTION(vec3_opDiv_f), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector@ opNeg() const", asFUNCTION(vec3_opNeg), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector& opAddAssign(const vector&in)", asFUNCTION(vec3_add_assign), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector& opSubAssign(const vector&in)", asFUNCTION(vec3_sub_assign), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector& opMulAssign(float)", asFUNCTION(vec3_mul_assign), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector& opDivAssign(float)", asFUNCTION(vec3_div_assign), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "bool opEquals(const vector&in) const", asFUNCTION(vec3_equals), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "float dot(const vector&in) const", asFUNCTION(vec3_dot), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector@ cross(const vector&in) const", asFUNCTION(vec3_cross), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "float length() const", asMETHOD(Vec3, Length), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float length_sq() const", asMETHOD(Vec3, LengthSq), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector@ normalized() const", asFUNCTION((scoped_ret<Vec3, Vec3, &Vec3::Normalized>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "bool is_normalized() const", asMETHOD(Vec3, IsNormalized), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool is_near_zero() const", asMETHOD(Vec3, IsNearZero), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float get_min_value() const property", asMETHOD(Vec3, ReduceMin), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float get_max_value() const property", asMETHOD(Vec3, ReduceMax), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector@ abs() const", asFUNCTION((scoped_ret<Vec3, Vec3, &Vec3::Abs>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "float get_opIndex(uint i) const property", asMETHODPR(Vec3, operator[], (uint) const, float), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void set_opIndex(uint i, float v) property", asMETHOD(Vec3, SetComponent), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "string opImplConv() const", asFUNCTION(vec3_to_string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "float length_square() const", asMETHOD(Vec3, LengthSq), asCALL_THISCALL);
	engine->RegisterGlobalFunction("vector@ get_VEC3_ZERO() property", asFUNCTION(vec3_sZero), asCALL_CDECL);
	engine->RegisterGlobalFunction("vector@ get_VEC3_ONE() property", asFUNCTION(vec3_sOne), asCALL_CDECL);
	engine->RegisterGlobalFunction("vector@ get_VEC3_AXIS_X() property", asFUNCTION(vec3_sAxisX), asCALL_CDECL);
	engine->RegisterGlobalFunction("vector@ get_VEC3_AXIS_Y() property", asFUNCTION(vec3_sAxisY), asCALL_CDECL);
	engine->RegisterGlobalFunction("vector@ get_VEC3_AXIS_Z() property", asFUNCTION(vec3_sAxisZ), asCALL_CDECL);
	engine->RegisterGlobalFunction("int clamp(int value, int min, int max)", asFUNCTION(nvgt_clamp_int), asCALL_CDECL);
	engine->RegisterGlobalFunction("float clamp(float value, float min, float max)", asFUNCTION(nvgt_clamp_float), asCALL_CDECL);

	// quaternion (Quat)
	engine->RegisterObjectType("quaternion", sizeof(Quat), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Quat>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(quat_default_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_CONSTRUCT, "void f(float x, float y, float z, float w)", asFUNCTION(quat_xyzw_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_CONSTRUCT, "void f(const quaternion&in)", asFUNCTION(quat_copy_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(jolt_destruct<Quat>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("quaternion", "float get_x() const property", asMETHOD(Quat, GetX), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float get_y() const property", asMETHOD(Quat, GetY), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float get_z() const property", asMETHOD(Quat, GetZ), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float get_w() const property", asMETHOD(Quat, GetW), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set_x(float) property", asMETHOD(Quat, SetX), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set_y(float) property", asMETHOD(Quat, SetY), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set_z(float) property", asMETHOD(Quat, SetZ), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set_w(float) property", asMETHOD(Quat, SetW), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion opMul(const quaternion&in) const", asMETHODPR(Quat, operator*, (QuatArg) const, Quat), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "vector@ opMul(const vector&in) const", asFUNCTION(quat_mul_vec3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("quaternion", "bool opEquals(const quaternion&in) const", asMETHODPR(Quat, operator==, (QuatArg) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float length() const", asMETHOD(Quat, Length), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion normalized() const", asMETHOD(Quat, Normalized), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion conjugated() const", asMETHOD(Quat, Conjugated), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion inversed() const", asMETHOD(Quat, Inversed), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "bool is_normalized() const", asMETHODPR(Quat, IsNormalized, (float) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float dot(const quaternion&in) const", asMETHOD(Quat, Dot), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float get_rotation_angle(const vector&in axis) const", asMETHOD(Quat, GetRotationAngle), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "vector@ rotate_axis_x() const", asFUNCTION((scoped_ret<Vec3, Quat, &Quat::RotateAxisX>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("quaternion", "vector@ rotate_axis_y() const", asFUNCTION((scoped_ret<Vec3, Quat, &Quat::RotateAxisY>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("quaternion", "vector@ rotate_axis_z() const", asFUNCTION((scoped_ret<Vec3, Quat, &Quat::RotateAxisZ>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("quaternion", "quaternion slerp(const quaternion&in dest, float t) const", asMETHOD(Quat, SLERP), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion lerp(const quaternion&in dest, float t) const", asMETHOD(Quat, LERP), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "string opImplConv() const", asFUNCTION(quat_to_string), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("quaternion get_IDENTITY_QUATERNION() property", asFUNCTION(Quat::sIdentity), asCALL_CDECL);
	engine->RegisterGlobalFunction("quaternion quaternion_from_axis_angle(const vector&in axis, float angle)", asFUNCTION(quaternion_from_axis_angle), asCALL_CDECL);
	engine->RegisterGlobalFunction("quaternion quaternion_from_euler_angles(const vector&in angles)", asFUNCTION(quaternion_from_euler_angles), asCALL_CDECL);

	// aabb (AABox) - scoped reference type; Vec3 members require 16-byte SIMD alignment that AS value types don't guarantee
	engine->RegisterObjectType("aabb", 0, asOBJ_REF | asOBJ_SCOPED);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_FACTORY, "aabb@ f()", asFUNCTION(aabb_factory_default), asCALL_CDECL);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_FACTORY, "aabb@ f(const vector&in min, const vector&in max)", asFUNCTION(aabb_factory_minmax), asCALL_CDECL);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_FACTORY, "aabb@ f(const vector&in center, float radius)", asFUNCTION(aabb_factory_center_radius), asCALL_CDECL);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_FACTORY, "aabb@ f(const aabb&in)", asFUNCTION(aabb_factory_copy), asCALL_CDECL);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_RELEASE, "void f()", asFUNCTION(aabb_release), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "vector@ get_min() const property", asFUNCTION(aabb_get_min), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "vector@ get_max() const property", asFUNCTION(aabb_get_max), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "void set_min(const vector&in) property", asFUNCTION(aabb_set_min), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "void set_max(const vector&in) property", asFUNCTION(aabb_set_max), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "vector@ get_center() const property", asFUNCTION((scoped_ret<Vec3, AABox, &AABox::GetCenter>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "vector@ get_extent() const property", asFUNCTION((scoped_ret<Vec3, AABox, &AABox::GetExtent>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "vector@ get_size() const property", asFUNCTION((scoped_ret<Vec3, AABox, &AABox::GetSize>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "float get_volume() const property", asMETHOD(AABox, GetVolume), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool get_is_valid() const property", asMETHOD(AABox, IsValid), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool contains(const vector&in point) const", asFUNCTION(aabb_contains_point), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "bool contains(const aabb&in box) const", asMETHODPR(AABox, Contains, (const AABox&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool overlaps(const aabb&in other) const", asMETHODPR(AABox, Overlaps, (const AABox&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void encapsulate(const vector&in point)", asFUNCTION(aabb_encapsulate_point), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "void encapsulate(const aabb&in box)", asMETHODPR(AABox, Encapsulate, (const AABox&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool opEquals(const aabb&in) const", asMETHODPR(AABox, operator==, (const AABox&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void inflate(float x, float y, float z)", asFUNCTION(aabb_inflate), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "void inflate_with_point(const vector&in point)", asFUNCTION(aabb_encapsulate_point), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "bool test_collision(const aabb&in other) const", asMETHODPR(AABox, Overlaps, (const AABox&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "aabb@ intersect(const aabb&in other) const", asFUNCTION((scoped_ret<AABox, AABox, &AABox::Intersect, const AABox&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "aabb& opAssign(const aabb&in)", asFUNCTION(aabb_opAssign), asCALL_CDECL_OBJFIRST);

	// physics_transform
	engine->RegisterObjectType("physics_transform", sizeof(physics_transform), asOBJ_VALUE | asGetTypeTraits<physics_transform>());
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(physics_transform_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_CONSTRUCT, "void f(const vector&in position, const quaternion&in rotation)", asFUNCTION(physics_transform_construct_pq), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_CONSTRUCT, "void f(const physics_transform&in)", asFUNCTION(jolt_copy_construct<physics_transform>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(physics_transform_destruct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "vector@ get_position() const property", asFUNCTION(physics_transform_get_position), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "void set_position(const vector&in) property", asFUNCTION(physics_transform_set_position), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "quaternion get_rotation() const property", asFUNCTION(physics_transform_get_rotation), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "void set_rotation(const quaternion&in) property", asFUNCTION(physics_transform_set_rotation), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "bool opEquals(const physics_transform&in) const", asMETHODPR(physics_transform, operator==, (const physics_transform&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectProperty("physics_transform", "float px", asOFFSET(physics_transform, px));
	engine->RegisterObjectProperty("physics_transform", "float py", asOFFSET(physics_transform, py));
	engine->RegisterObjectProperty("physics_transform", "float pz", asOFFSET(physics_transform, pz));
	engine->RegisterObjectProperty("physics_transform", "float qx", asOFFSET(physics_transform, qx));
	engine->RegisterObjectProperty("physics_transform", "float qy", asOFFSET(physics_transform, qy));
	engine->RegisterObjectProperty("physics_transform", "float qz", asOFFSET(physics_transform, qz));
	engine->RegisterObjectProperty("physics_transform", "float qw", asOFFSET(physics_transform, qw));
	engine->RegisterGlobalFunction("physics_transform get_IDENTITY_TRANSFORM() property", asFUNCTION(jolt_identity_transform), asCALL_CDECL);
}

static void RegisterJoltEnums(asIScriptEngine* engine) {
	engine->RegisterEnum("physics_body_type");
	engine->RegisterEnumValue("physics_body_type", "PHYSICS_BODY_STATIC", (int)EMotionType::Static);
	engine->RegisterEnumValue("physics_body_type", "PHYSICS_BODY_KINEMATIC", (int)EMotionType::Kinematic);
	engine->RegisterEnumValue("physics_body_type", "PHYSICS_BODY_DYNAMIC", (int)EMotionType::Dynamic);

	engine->RegisterEnum("physics_object_layer");
	engine->RegisterEnumValue("physics_object_layer", "PHYSICS_LAYER_NON_MOVING", (int)JoltLayers::NON_MOVING);
	engine->RegisterEnumValue("physics_object_layer", "PHYSICS_LAYER_MOVING", (int)JoltLayers::MOVING);

	engine->RegisterEnum("physics_activation");
	engine->RegisterEnumValue("physics_activation", "PHYSICS_ACTIVATE", (int)EActivation::Activate);
	engine->RegisterEnumValue("physics_activation", "PHYSICS_DONT_ACTIVATE", (int)EActivation::DontActivate);

	engine->RegisterEnum("physics_motion_quality");
	engine->RegisterEnumValue("physics_motion_quality", "PHYSICS_MOTION_QUALITY_DISCRETE", (int)EMotionQuality::Discrete);
	engine->RegisterEnumValue("physics_motion_quality", "PHYSICS_MOTION_QUALITY_LINEAR_CAST", (int)EMotionQuality::LinearCast);

	engine->RegisterEnum("physics_shape_type");
	engine->RegisterEnumValue("physics_shape_type", "PHYSICS_SHAPE_CONVEX", (int)EShapeType::Convex);
	engine->RegisterEnumValue("physics_shape_type", "PHYSICS_SHAPE_COMPOUND", (int)EShapeType::Compound);
	engine->RegisterEnumValue("physics_shape_type", "PHYSICS_SHAPE_MESH", (int)EShapeType::Mesh);
	engine->RegisterEnumValue("physics_shape_type", "PHYSICS_SHAPE_HEIGHT_FIELD", (int)EShapeType::HeightField);

	engine->RegisterEnum("physics_shape_sub_type");
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_SPHERE", (int)EShapeSubType::Sphere);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_BOX", (int)EShapeSubType::Box);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_TRIANGLE", (int)EShapeSubType::Triangle);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_CAPSULE", (int)EShapeSubType::Capsule);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_CYLINDER", (int)EShapeSubType::Cylinder);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_CONVEX_HULL", (int)EShapeSubType::ConvexHull);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_STATIC_COMPOUND", (int)EShapeSubType::StaticCompound);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_MUTABLE_COMPOUND", (int)EShapeSubType::MutableCompound);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_MESH_SUBTYPE", (int)EShapeSubType::Mesh);
	engine->RegisterEnumValue("physics_shape_sub_type", "PHYSICS_SHAPE_HEIGHT_FIELD_SUBTYPE", (int)EShapeSubType::HeightField);
}

static void RegisterJoltBodyID(asIScriptEngine* engine) {
	engine->RegisterObjectType("physics_body_id", sizeof(BodyID), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<BodyID>());
	engine->RegisterObjectBehaviour("physics_body_id", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(body_id_default_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_body_id", asBEHAVE_CONSTRUCT, "void f(uint raw_id)", asFUNCTION(body_id_uint_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_body_id", asBEHAVE_CONSTRUCT, "void f(const physics_body_id&in)", asFUNCTION(body_id_copy_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_body_id", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(jolt_destruct<BodyID>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_body_id", "bool get_is_invalid() const property", asMETHOD(BodyID, IsInvalid), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_body_id", "uint get_index() const property", asMETHOD(BodyID, GetIndex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_body_id", "uint8 get_sequence_number() const property", asMETHOD(BodyID, GetSequenceNumber), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_body_id", "uint get_raw() const property", asMETHOD(BodyID, GetIndexAndSequenceNumber), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_body_id", "bool opEquals(const physics_body_id&in) const", asMETHODPR(BodyID, operator==, (const BodyID&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_body_id", "string opImplConv() const", asFUNCTION(body_id_to_string), asCALL_CDECL_OBJFIRST);
}

static void RegisterJoltShape(asIScriptEngine* engine) {
	// All shape types are backed by jolt_shape_ref* — AddRef/Release are shared
	// Forward declare shape types
	engine->RegisterObjectType("physics_convex_shape", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_sphere_shape", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_box_shape", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_capsule_shape", 0, asOBJ_REF);
	// physics_shape (base)
	engine->RegisterObjectType("physics_shape", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_shape", asBEHAVE_ADDREF, "void f()", asMETHOD(jolt_shape_ref, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_shape", asBEHAVE_RELEASE, "void f()", asMETHOD(jolt_shape_ref, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_shape", "uint8 get_type() const property", asFUNCTION(jolt_shape_get_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_shape", "uint8 get_sub_type() const property", asFUNCTION(jolt_shape_get_sub_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_shape", "aabb@ get_local_bounds() const property", asFUNCTION(jolt_shape_get_local_bounds), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_shape", "float get_volume() const property", asFUNCTION(jolt_shape_get_volume), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_shape", "physics_convex_shape@ opCast()", asFUNCTION(jolt_shape_to_convex), asCALL_CDECL_OBJFIRST);

	// jolt_convex_shape
	engine->RegisterObjectBehaviour("physics_convex_shape", asBEHAVE_ADDREF, "void f()", asMETHOD(jolt_shape_ref, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_convex_shape", asBEHAVE_RELEASE, "void f()", asMETHOD(jolt_shape_ref, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_shape", "uint8 get_type() const property", asFUNCTION(jolt_shape_get_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "uint8 get_sub_type() const property", asFUNCTION(jolt_shape_get_sub_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "aabb@ get_local_bounds() const property", asFUNCTION(jolt_shape_get_local_bounds), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "float get_volume() const property", asFUNCTION(jolt_shape_get_volume), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "float get_density() const property", asFUNCTION(jolt_convex_shape_get_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "void set_density(float) property", asFUNCTION(jolt_convex_shape_set_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "physics_material@ get_material() const property", asFUNCTION(jolt_convex_shape_get_material), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "physics_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "physics_sphere_shape@ opCast()", asFUNCTION(jolt_convex_to_sphere), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "physics_box_shape@ opCast()", asFUNCTION(jolt_convex_to_box), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_shape", "physics_capsule_shape@ opCast()", asFUNCTION(jolt_convex_to_capsule), asCALL_CDECL_OBJFIRST);

	// jolt_sphere_shape
	engine->RegisterObjectBehaviour("physics_sphere_shape", asBEHAVE_ADDREF, "void f()", asMETHOD(jolt_shape_ref, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_sphere_shape", asBEHAVE_RELEASE, "void f()", asMETHOD(jolt_shape_ref, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_sphere_shape", "uint8 get_type() const property", asFUNCTION(jolt_shape_get_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "uint8 get_sub_type() const property", asFUNCTION(jolt_shape_get_sub_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "aabb@ get_local_bounds() const property", asFUNCTION(jolt_shape_get_local_bounds), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "float get_volume() const property", asFUNCTION(jolt_shape_get_volume), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "float get_density() const property", asFUNCTION(jolt_convex_shape_get_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "void set_density(float) property", asFUNCTION(jolt_convex_shape_set_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "physics_material@ get_material() const property", asFUNCTION(jolt_convex_shape_get_material), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "float get_radius() const property", asFUNCTION(jolt_sphere_shape_get_radius), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "physics_convex_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_sphere_shape", "physics_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);

	// jolt_box_shape
	engine->RegisterObjectBehaviour("physics_box_shape", asBEHAVE_ADDREF, "void f()", asMETHOD(jolt_shape_ref, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_box_shape", asBEHAVE_RELEASE, "void f()", asMETHOD(jolt_shape_ref, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_box_shape", "uint8 get_type() const property", asFUNCTION(jolt_shape_get_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "uint8 get_sub_type() const property", asFUNCTION(jolt_shape_get_sub_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "aabb@ get_local_bounds() const property", asFUNCTION(jolt_shape_get_local_bounds), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "float get_volume() const property", asFUNCTION(jolt_shape_get_volume), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "float get_density() const property", asFUNCTION(jolt_convex_shape_get_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "void set_density(float) property", asFUNCTION(jolt_convex_shape_set_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "physics_material@ get_material() const property", asFUNCTION(jolt_convex_shape_get_material), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "vector@ get_half_extent() const property", asFUNCTION(jolt_box_shape_get_half_extent), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "float get_convex_radius() const property", asFUNCTION(jolt_box_shape_get_convex_radius), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "physics_convex_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_box_shape", "physics_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);

	// jolt_capsule_shape
	engine->RegisterObjectBehaviour("physics_capsule_shape", asBEHAVE_ADDREF, "void f()", asMETHOD(jolt_shape_ref, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_capsule_shape", asBEHAVE_RELEASE, "void f()", asMETHOD(jolt_shape_ref, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "uint8 get_type() const property", asFUNCTION(jolt_shape_get_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "uint8 get_sub_type() const property", asFUNCTION(jolt_shape_get_sub_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "aabb@ get_local_bounds() const property", asFUNCTION(jolt_shape_get_local_bounds), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_volume() const property", asFUNCTION(jolt_shape_get_volume), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_density() const property", asFUNCTION(jolt_convex_shape_get_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "void set_density(float) property", asFUNCTION(jolt_convex_shape_set_density), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "physics_material@ get_material() const property", asFUNCTION(jolt_convex_shape_get_material), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_half_height() const property", asFUNCTION(jolt_capsule_shape_get_half_height), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_radius() const property", asFUNCTION(jolt_capsule_shape_get_radius), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "physics_convex_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_capsule_shape", "physics_shape@ opImplCast()", asFUNCTION(jolt_shape_ref_upcast), asCALL_CDECL_OBJFIRST);

	// Factory functions return specific typed shapes
	engine->RegisterGlobalFunction("physics_sphere_shape@ physics_sphere_shape_create(float radius, physics_material@ mat = null)", asFUNCTION(jolt_sphere_shape_create), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_box_shape@ physics_box_shape_create(const vector&in half_extents, float convex_radius = 0.05f, physics_material@ mat = null)", asFUNCTION(jolt_box_shape_create), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_capsule_shape@ physics_capsule_shape_create(float half_height, float radius, physics_material@ mat = null)", asFUNCTION(jolt_capsule_shape_create), asCALL_CDECL);
}

static void RegisterJoltWorld(asIScriptEngine* engine) {
	engine->RegisterFuncdef("void physics_contact_added_callback(const physics_body_id&in body1, const physics_body_id&in body2, const vector&in world_normal, float penetration_depth)");
	engine->RegisterFuncdef("void physics_contact_persisted_callback(const physics_body_id&in body1, const physics_body_id&in body2, const vector&in world_normal, float penetration_depth)");
	engine->RegisterFuncdef("void physics_contact_removed_callback(const physics_body_id&in body1, const physics_body_id&in body2)");

	engine->RegisterObjectType("physics_world", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_FACTORY, "physics_world@ f(uint max_bodies = 1024, uint max_body_pairs = 1024, uint max_contact_constraints = 1024)", asFUNCTION(jolt_world_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_ADDREF, "void f()", asMETHOD(jolt_physics_world, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_RELEASE, "void f()", asMETHOD(jolt_physics_world, Release), asCALL_THISCALL);

	// Simulation
	engine->RegisterObjectMethod("physics_world", "void update(float delta_time, int collision_steps = 1)", asFUNCTION(jolt_world_update), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void optimize_broadphase()", asFUNCTION(jolt_world_optimize_broadphase), asCALL_CDECL_OBJFIRST);

	// Gravity
	engine->RegisterObjectMethod("physics_world", "vector@ get_gravity() const property", asFUNCTION(jolt_world_get_gravity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_gravity(const vector&in) property", asFUNCTION(jolt_world_set_gravity), asCALL_CDECL_OBJFIRST);

	// Body counts
	engine->RegisterObjectMethod("physics_world", "uint get_num_bodies() const property", asFUNCTION(jolt_world_get_num_bodies), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "uint get_num_active_bodies() const property", asFUNCTION(jolt_world_get_num_active_bodies), asCALL_CDECL_OBJFIRST);

	// Body lifecycle
	engine->RegisterObjectMethod("physics_world", "physics_body_id create_and_add_body(physics_shape@ shape, const vector&in position, const quaternion&in rotation, physics_body_type motion_type, uint16 layer = PHYSICS_LAYER_MOVING, physics_activation activation = PHYSICS_ACTIVATE)", asFUNCTION(jolt_world_create_and_add_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void remove_body(const physics_body_id&in id)", asFUNCTION(jolt_world_remove_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void destroy_body(const physics_body_id&in id)", asFUNCTION(jolt_world_destroy_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void remove_and_destroy_body(const physics_body_id&in id)", asFUNCTION(jolt_world_remove_and_destroy_body), asCALL_CDECL_OBJFIRST);

	// Transform
	engine->RegisterObjectMethod("physics_world", "vector@ get_position(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_position), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_position(const physics_body_id&in id, const vector&in pos, physics_activation activation = JOLT_ACTIVATE)", asFUNCTION(jolt_world_set_position), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "quaternion get_rotation(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_rotation), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_rotation(const physics_body_id&in id, const quaternion&in rot, physics_activation activation = JOLT_ACTIVATE)", asFUNCTION(jolt_world_set_rotation), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_position_and_rotation(const physics_body_id&in id, const vector&in pos, const quaternion&in rot, physics_activation activation = JOLT_ACTIVATE)", asFUNCTION(jolt_world_set_position_and_rotation), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "vector@ get_center_of_mass_position(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_center_of_mass_position), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "physics_transform get_transform(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_transform), asCALL_CDECL_OBJFIRST);

	// Velocity
	engine->RegisterObjectMethod("physics_world", "vector@ get_linear_velocity(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_linear_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_linear_velocity(const physics_body_id&in id, const vector&in v)", asFUNCTION(jolt_world_set_linear_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "vector@ get_angular_velocity(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_angular_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_angular_velocity(const physics_body_id&in id, const vector&in v)", asFUNCTION(jolt_world_set_angular_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void add_linear_velocity(const physics_body_id&in id, const vector&in v)", asFUNCTION(jolt_world_add_linear_velocity), asCALL_CDECL_OBJFIRST);

	// Forces / impulses
	engine->RegisterObjectMethod("physics_world", "void add_force(const physics_body_id&in id, const vector&in force)", asFUNCTION(jolt_world_add_force), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void add_force(const physics_body_id&in id, const vector&in force, const vector&in point)", asFUNCTION(jolt_world_add_force_at), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void add_torque(const physics_body_id&in id, const vector&in torque)", asFUNCTION(jolt_world_add_torque), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void add_impulse(const physics_body_id&in id, const vector&in impulse)", asFUNCTION(jolt_world_add_impulse), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void add_impulse(const physics_body_id&in id, const vector&in impulse, const vector&in point)", asFUNCTION(jolt_world_add_impulse_at), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void add_angular_impulse(const physics_body_id&in id, const vector&in impulse)", asFUNCTION(jolt_world_add_angular_impulse), asCALL_CDECL_OBJFIRST);

	// Activation
	engine->RegisterObjectMethod("physics_world", "void activate_body(const physics_body_id&in id)", asFUNCTION(jolt_world_activate_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void deactivate_body(const physics_body_id&in id)", asFUNCTION(jolt_world_deactivate_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "bool is_active(const physics_body_id&in id) const", asFUNCTION(jolt_world_is_active), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "bool is_added(const physics_body_id&in id) const", asFUNCTION(jolt_world_is_added), asCALL_CDECL_OBJFIRST);

	// Motion type
	engine->RegisterObjectMethod("physics_world", "void set_motion_type(const physics_body_id&in id, physics_body_type type, physics_activation activation = JOLT_ACTIVATE)", asFUNCTION(jolt_world_set_motion_type), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "physics_body_type get_motion_type(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_motion_type), asCALL_CDECL_OBJFIRST);

	// Shape
	engine->RegisterObjectMethod("physics_world", "void set_shape(const physics_body_id&in id, physics_shape@ shape, bool update_mass = true, physics_activation activation = JOLT_ACTIVATE)", asFUNCTION(jolt_world_set_shape), asCALL_CDECL_OBJFIRST);

	// Material properties
	engine->RegisterObjectMethod("physics_world", "float get_friction(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_friction), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_friction(const physics_body_id&in id, float v)", asFUNCTION(jolt_world_set_friction), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "float get_restitution(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_restitution), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_restitution(const physics_body_id&in id, float v)", asFUNCTION(jolt_world_set_restitution), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "float get_gravity_factor(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_gravity_factor), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_gravity_factor(const physics_body_id&in id, float v)", asFUNCTION(jolt_world_set_gravity_factor), asCALL_CDECL_OBJFIRST);

	// Spatial queries
	engine->RegisterObjectMethod("physics_world", "aabb@ get_world_space_bounds(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_world_space_bounds), asCALL_CDECL_OBJFIRST);

	// Velocity limits
	engine->RegisterObjectMethod("physics_world", "float get_max_linear_velocity(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_max_linear_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_max_linear_velocity(const physics_body_id&in id, float v)", asFUNCTION(jolt_world_set_max_linear_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "float get_max_angular_velocity(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_max_angular_velocity), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void set_max_angular_velocity(const physics_body_id&in id, float v)", asFUNCTION(jolt_world_set_max_angular_velocity), asCALL_CDECL_OBJFIRST);

	// Buoyancy
	engine->RegisterObjectMethod("physics_world", "bool apply_buoyancy_impulse(const physics_body_id&in id, const vector&in surface_pos, const vector&in surface_normal, float buoyancy, float linear_drag, float angular_drag, const vector&in fluid_velocity, const vector&in gravity, float delta_time)", asFUNCTION(jolt_world_apply_buoyancy_impulse), asCALL_CDECL_OBJFIRST);

	// Kinematic
	engine->RegisterObjectMethod("physics_world", "void move_kinematic(const physics_body_id&in id, const vector&in target_pos, const quaternion&in target_rot, float delta_time)", asFUNCTION(jolt_world_move_kinematic), asCALL_CDECL_OBJFIRST);

	// Contact query
	engine->RegisterObjectMethod("physics_world", "bool were_bodies_in_contact(const physics_body_id&in a, const physics_body_id&in b) const", asFUNCTION(jolt_world_were_bodies_in_contact), asCALL_CDECL_OBJFIRST);

	// Raycast
	engine->RegisterObjectMethod("physics_world", "bool cast_ray(const vector&in origin, const vector&in direction, physics_body_id&out hit_body, float&out hit_fraction) const", asFUNCTION(jolt_world_cast_ray), asCALL_CDECL_OBJFIRST);

	// User data
	engine->RegisterObjectMethod("physics_world", "void set_user_data(const physics_body_id&in id, any@ data)", asFUNCTION(jolt_world_set_user_data), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "any@ get_user_data(const physics_body_id&in id) const", asFUNCTION(jolt_world_get_user_data), asCALL_CDECL_OBJFIRST);

	// Contact listener
	engine->RegisterObjectMethod("physics_world", "void set_contact_listener(physics_contact_added_callback@ on_added, physics_contact_persisted_callback@ on_persisted, physics_contact_removed_callback@ on_removed)", asFUNCTION(jolt_world_set_contact_listener), asCALL_CDECL_OBJFIRST);
}

void RegisterJolt(asIScriptEngine* engine) {
	jolt_ensure_init();
	RegisterJoltMaterial(engine);
	RegisterJoltMathTypes(engine);
	RegisterJoltEnums(engine);
	RegisterJoltBodyID(engine);
	RegisterJoltShape(engine);
	RegisterJoltWorld(engine);
}
