/* reactphysics.cpp - reactphysics3d wrapper integration
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
#include <scriptany.h>
#include <scriptarray.h>
#include <reactphysics3d/reactphysics3d.h>
#include "nvgt.h"
#include "nvgt_angelscript.h"
#include "reactphysics.h"

using namespace std;
using namespace reactphysics3d;
class event_listener;

PhysicsCommon g_physics;
unordered_map<PhysicsWorld*, event_listener*> g_physics_event_listeners; // These need to be kept alive while the world exists, and the PhysicsWorld class has no user data.

// Angelscript factories.
template <class T, typename... A> void rp_construct(void* mem, A... args) { new (mem) T(args...); }
template <class T> void rp_copy_construct(void* mem, const T& obj) { new(mem) T(obj); }
template <class T> void rp_destruct(T* obj) { obj->~T(); }

// No-Op ref counting function. This is needed because reactphysics has it's own memory management that does not include reference counting and until we find a way to make things safer, we'll just have to go with that for now. Many handles returned to the script from this library will be similar to raw pointers, it will be possible for objects to be deleted without all script references being released!
void no_refcount(void* obj) {}

// Some functions require manual wrapping, especially anything dealing with arrays or force inline.
CScriptArray* transform_get_opengl_matrix(const Transform& t) {
	CScriptArray* array = CScriptArray::Create(get_array_type("array<float>"), 16);
	t.getOpenGLMatrix(reinterpret_cast<float*>(array->GetBuffer()));
	return array;
}
void transform_set_from_opengl_matrix(Transform& t, CScriptArray* matrix) {
	if (matrix->GetSize() != 16) throw runtime_error("opengl matrix must have length of 16");
	t.setFromOpenGL(reinterpret_cast<decimal*>(matrix->GetBuffer()));
}
bool aabb_test_collision_triangle(const AABB& aabb, CScriptArray* points) {
	if (points->GetSize() != 3) throw runtime_error("triangle must have 3 points");
	return aabb.testCollisionTriangleAABB(reinterpret_cast<const Vector3*>(points->GetBuffer()));
}
AABB aabb_from_triangle(CScriptArray* points) {
	if (points->GetSize() != 3) throw runtime_error("triangle must have 3 points");
	return AABB::createAABBForTriangle(reinterpret_cast<const Vector3*>(points->GetBuffer()));
}
void simple_void_callback(asIScriptFunction* callback, const void* data) {
	asIScriptContext* ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext* ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
	if (!ctx) return;
	if (ctx->Prepare(callback) < 0) {
		if (new_context) g_ScriptEngine->ReturnContext(ctx);
		else ctx->PopState();
		return;
	}
	ctx->SetArgObject(0, (void*)&data);
	ctx->Execute();
	if (new_context) g_ScriptEngine->ReturnContext(ctx);
	else ctx->PopState();
}
class raycast_callback : public RaycastCallback {
	public:
	asIScriptFunction* callback;
	raycast_callback(asIScriptFunction* callback) : callback(callback) {}
	decimal notifyRaycastHit(const RaycastInfo& info) override {
		asIScriptContext* ACtx = asGetActiveContext();
		bool new_context = ACtx == NULL || ACtx->PushState() < 0;
		asIScriptContext* ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
		if (!ctx) return 0;
		if (ctx->Prepare(callback) < 0) {
			if (new_context) g_ScriptEngine->ReturnContext(ctx);
			else ctx->PopState();
			return 0;
		}
		ctx->SetArgObject(0, (void*)&info);
		if (ctx->Execute() != asEXECUTION_FINISHED) {
			if (new_context) g_ScriptEngine->ReturnContext(ctx);
			else ctx->PopState();
			return 0;
		}
		float v = ctx->GetReturnFloat();
		if (new_context) g_ScriptEngine->ReturnContext(ctx);
		else ctx->PopState();
		return v;
	}
};
class collision_callback : public CollisionCallback {
	public:
	asIScriptFunction* callback;
	collision_callback(asIScriptFunction* callback) : callback(callback) {}
	void onContact(const CollisionCallback::CallbackData& data) override { simple_void_callback(callback, &data); }
};
class overlap_callback : public OverlapCallback {
	public:
	asIScriptFunction* callback;
	overlap_callback(asIScriptFunction* callback) : callback(callback) {}
	void onOverlap(OverlapCallback::CallbackData& data) override { simple_void_callback(callback, &data); }
};
class event_listener : public EventListener {
	public:
	asIScriptFunction* on_contact_callback;
	asIScriptFunction* on_overlap_callback;
	event_listener(asIScriptFunction* on_contact_callback, asIScriptFunction* on_overlap_callback) : on_contact_callback(on_contact_callback), on_overlap_callback(on_overlap_callback) {}
	void onContact(const CollisionCallback::CallbackData& data) override { simple_void_callback(on_contact_callback, &data); }
	void onTrigger(const OverlapCallback::CallbackData& data) override { simple_void_callback(on_overlap_callback, &data); }
};

void world_raycast(PhysicsWorld& world, const Ray& ray, asIScriptFunction* callback, unsigned short bits) {
	raycast_callback rcb(callback);
	world.raycast(ray, &rcb, bits);
}
void world_test_overlap_body(PhysicsWorld& world, Body* body, asIScriptFunction* callback) {
	overlap_callback cb(callback);
	world.testOverlap(body, cb);
}
void world_test_overlap(PhysicsWorld& world, asIScriptFunction* callback) {
	overlap_callback cb(callback);
	world.testOverlap(cb);
}
void world_test_collision_bodies(PhysicsWorld& world, Body* body1, Body* body2, asIScriptFunction* callback) {
	collision_callback cb(callback);
	world.testCollision(body1, body2, cb);
}
void world_test_collision_body(PhysicsWorld& world, Body* body, asIScriptFunction* callback) {
	collision_callback cb(callback);
	world.testCollision(body, cb);
}
void world_test_collision(PhysicsWorld& world, asIScriptFunction* callback) {
	collision_callback cb(callback);
	world.testCollision(cb);
}
void world_destroy_listener(PhysicsWorld* world) {
	if (!g_physics_event_listeners.contains(world)) return;
	event_listener* l = g_physics_event_listeners[world];
	if(l->on_contact_callback) l->on_contact_callback->Release();
	if(l->on_overlap_callback) l->on_overlap_callback->Release();
	delete l;
	g_physics_event_listeners.erase(world);
}
void world_set_callbacks(PhysicsWorld* world, asIScriptFunction* on_contact, asIScriptFunction* on_overlap) {
	world_destroy_listener(world);
	g_physics_event_listeners[world] = new event_listener(on_contact, on_overlap);
	world->setEventListener(g_physics_event_listeners[world]);
}
void world_destroy(PhysicsWorld* world) {
	world_destroy_listener(world);
	g_physics.destroyPhysicsWorld(world);
}

CScriptArray* face_get_vertices(const HalfEdgeStructure::Face & f) {
	CScriptArray* array = CScriptArray::Create(get_array_type("array<uint>"), f.faceVertices.size());
	memcpy(array->GetBuffer(), &f.faceVertices[0], f.faceVertices.size()*sizeof(uint32));
	return array;
}
void face_set_vertices(HalfEdgeStructure::Face & f, CScriptArray* array) {
	f.faceVertices.clear();
	f.faceVertices.reserve(array->GetSize());
	memcpy(&f.faceVertices[0], array->GetBuffer(), array->GetSize()*sizeof(uint32));
}


// registration templates
template <class T> void RegisterCollisionShape(asIScriptEngine* engine, const string& type) {
	engine->RegisterObjectType(type.c_str(), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "physics_shape_name get_name() const property", asMETHOD(T, getName), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "physics_shape_type get_type() const property", asMETHOD(T, getType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_convex() const property", asMETHOD(T, isConvex), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_polyhedron() const property", asMETHOD(T, isPolyhedron), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "aabb get_local_bounds() const", asMETHOD(T, getLocalBounds), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_id() const property", asMETHOD(T, getId), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_local_inertia_tensor(float mass) const", asMETHOD(T, getLocalInertiaTensor), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "float get_volume() const property", asMETHOD(T, getVolume), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "aabb compute_transformed_aabb(const transform&in transform) const", asMETHOD(T, computeTransformedAABB), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string opImplConv() const", asMETHOD(T, to_string), asCALL_THISCALL);
}
template <class T> void RegisterPhysicsBody(asIScriptEngine* engine, const string& type) {
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "physics_entity get_entity() const property", asMETHOD(T, getEntity), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_active() const property", asMETHOD(T, isActive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_is_active(bool is_active) property", asMETHOD(T, setIsActive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const transform& get_transform() const property", asMETHOD(T, getTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_transform(const transform&in transform) property", asMETHOD(T, setTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "physics_collider@ add_collider(physics_collision_shape&in shape, const transform&in transform)", asMETHOD(T, addCollider), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove_collider(physics_collider&in collider)", asMETHOD(T, removeCollider), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool test_point_inside(const vector&in point) const", asMETHOD(T, testPointInside), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool raycast(const ray& point, raycast_info& raycast_info) const", asMETHOD(T, raycast), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool test_aabb_overlap(const aabb&in world_aabb) const", asMETHOD(T, testAABBOverlap), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "aabb get_aabb() const property", asMETHOD(T, getAABB), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const physics_collider& get_collider(uint index) const", asMETHODPR(T, getCollider, (uint32) const, const Collider*), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "physics_collider& get_collider(uint index)", asMETHODPR(T, getCollider, (uint32), Collider*), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "uint get_nb_colliders() const property", asMETHOD(T, getNbColliders), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_world_point(const vector&in local_point) const", asMETHOD(T, getWorldPoint), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_world_vector(const vector&in local_vector) const", asMETHOD(T, getWorldVector), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_local_point(const vector&in world_point) const", asMETHOD(T, getLocalPoint), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_local_vector(const vector&in world_vector) const", asMETHOD(T, getLocalVector), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_debug_enabled() const property", asMETHOD(T, isDebugEnabled), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_debug_enabled(bool enabled) property", asMETHOD(T, setIsDebugEnabled), asCALL_THISCALL);
}

template <class T> void RegisterConvexShape(asIScriptEngine* engine, const string& type) {
	RegisterCollisionShape<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "float get_margin() const property", asMETHOD(T, getMargin), asCALL_THISCALL);
}

template <class T> void RegisterConvexPolyhedronShape(asIScriptEngine* engine, const string& type) {
	RegisterConvexShape<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "uint get_nb_faces() const property", asMETHOD(T, getNbFaces), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const physics_half_edge_structure_face& get_face(uint face_index)", asMETHOD(T, getFace), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "uint get_nb_vertices() const property", asMETHOD(T, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const physics_half_edge_structure_vertex& get_vertex(uint vertex_index)", asMETHOD(T, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const vector get_vertex_position(uint vertex_index)", asMETHOD(T, getVertexPosition), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const vector get_face_normal(uint vertex_index)", asMETHOD(T, getFaceNormal), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "uint get_nb_half_edges() const property", asMETHOD(T, getNbHalfEdges), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const physics_half_edge_structure_edge& get_half_edge(uint edge_index) const", asMETHOD(T, getHalfEdge), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_centroid() const property", asMETHOD(T, getCentroid), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "uint find_most_anti_parallel_face(const vector&in direction) const", asMETHOD(T, findMostAntiParallelFace), asCALL_THISCALL);
}

template <class T> void RegisterConcaveShape(asIScriptEngine* engine, const string& type) {
	RegisterCollisionShape<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "physics_triangle_raycast_side get_raycast_test_type() const property", asMETHOD(ConcaveShape, getRaycastTestType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_raycast_test_type(physics_triangle_raycast_side side) property", asMETHOD(ConcaveShape, setRaycastTestType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_scale() const property", asMETHOD(ConcaveShape, getScale), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_scale(const vector &in scale) property", asMETHOD(ConcaveShape, setScale), asCALL_THISCALL);
}

void RegisterReactphysics(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction("int clamp(int value, int min, int max)", asFUNCTIONPR(clamp, (int, int, int), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("float clamp(float value, float min, float max)", asFUNCTIONPR(clamp, (decimal, decimal, decimal), decimal), asCALL_CDECL);

	engine->RegisterEnum("physics_body_type");
	engine->RegisterEnumValue("physics_body_type", "PHYSICS_BODY_STATIC", int(BodyType::STATIC));
	engine->RegisterEnumValue("physics_body_type", "PHYSICS_BODY_KINEMATIC", int(BodyType::KINEMATIC));
	engine->RegisterEnumValue("physics_body_type", "PHYSICS_BODY_DYNAMIC", int(BodyType::DYNAMIC));
	engine->RegisterEnum("physics_shape_type");
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_SPHERE", int(CollisionShapeType::SPHERE));
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_CAPSULE", int(CollisionShapeType::CAPSULE));
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_CONVEX_POLYHEDRON", int(CollisionShapeType::CONVEX_POLYHEDRON));
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_CONCAVE", int(CollisionShapeType::CONCAVE_SHAPE));
	engine->RegisterEnum("physics_shape_name");
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_TRIANGLE", int(CollisionShapeName::TRIANGLE));
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_SPHERE", int(CollisionShapeName::SPHERE));
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_CAPSULE", int(CollisionShapeName::CAPSULE));
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_BOX", int(CollisionShapeName::BOX));
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_CONVEX_MESH", int(CollisionShapeName::CONVEX_MESH));
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_TRIANGLE_MESH", int(CollisionShapeName::TRIANGLE_MESH));
	engine->RegisterEnumValue("physics_shape_name", "SHAPE_HEIGHTFIELD", int(CollisionShapeName::HEIGHTFIELD));

	engine->RegisterEnum("physics_overlap_event_type");
	engine->RegisterEnumValue("physics_overlap_event_type", "PHYSICS_OVERLAP_START", int(OverlapCallback::OverlapPair::EventType::OverlapStart));
	engine->RegisterEnumValue("physics_overlap_event_type", "PHYSICS_OVERLAP_STAY", int(OverlapCallback::OverlapPair::EventType::OverlapStay));
	engine->RegisterEnumValue("physics_overlap_event_type", "PHYSICS_OVERLAP_EXIT", int(OverlapCallback::OverlapPair::EventType::OverlapExit));
	engine->RegisterEnum("physics_contact_event_type");
	engine->RegisterEnumValue("physics_contact_event_type", "PHYSICS_CONTACT_START", int(CollisionCallback::ContactPair::EventType::ContactStart));
	engine->RegisterEnumValue("physics_contact_event_type", "PHYSICS_CONTACT_STAY", int(CollisionCallback::ContactPair::EventType::ContactStay));
	engine->RegisterEnumValue("physics_contact_event_type", "PHYSICS_CONTACT_EXIT", int(CollisionCallback::ContactPair::EventType::ContactExit));

	engine->RegisterEnum("physics_joints_position_correction_technique");
	engine->RegisterEnumValue("physics_joints_position_correction_technique", "JOINTS_CORRECTION_TECHNIQUE_BAUMGARTE_JOINTS", int(JointsPositionCorrectionTechnique::BAUMGARTE_JOINTS));
	engine->RegisterEnumValue("physics_joints_position_correction_technique", "JOINTS_CORRECTION_TECHNIQUE_NON_LINEAR_GAUSS_SEIDEL", int(JointsPositionCorrectionTechnique::NON_LINEAR_GAUSS_SEIDEL));
	engine->RegisterEnum("physics_contact_position_correction_technique");
	engine->RegisterEnumValue("physics_contact_position_correction_technique", "POSITION_CORRECTION_TECHNIQUE_BAUMGARTE_CONTACTS", int(ContactsPositionCorrectionTechnique::BAUMGARTE_CONTACTS));
	engine->RegisterEnumValue("physics_contact_position_correction_technique", "POSITION_CORRECTION_TECHNIQUE_SPLIT_IMPULSES", int(ContactsPositionCorrectionTechnique::SPLIT_IMPULSES));

	engine->RegisterEnum("physics_triangle_raycast_side");
	engine->RegisterEnumValue("physics_triangle_raycast_side", "TRIANGLE_RAYCAST_SIDE_FRONT", int(TriangleRaycastSide::FRONT));
	engine->RegisterEnumValue("physics_triangle_raycast_side", "TRIANGLE_RAYCAST_SIDE_BACK", int(TriangleRaycastSide::BACK));
	engine->RegisterEnumValue("physics_triangle_raycast_side", "TRIANGLE_RAYCAST_SIDE_FRONT_AND_BACK", int(TriangleRaycastSide::FRONT_AND_BACK));

	engine->RegisterGlobalProperty("const float EPSILON", (void*)&MACHINE_EPSILON);

	engine->RegisterObjectType("physics_entity", sizeof(Entity), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Entity>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("physics_entity", asBEHAVE_CONSTRUCT, "void f(uint index, uint generation)", asFUNCTION((rp_construct<Entity, uint32, uint32>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_entity", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Entity>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_entity", "uint id", asOFFSET(Entity, id));
	engine->RegisterObjectMethod("physics_entity", "uint get_index() const property", asMETHOD(Entity, getIndex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_entity", "uint get_generation() const property", asMETHOD(Entity, getGeneration), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_entity", "bool opEquals(const physics_entity&in entity) const", asMETHOD(Entity, operator==), asCALL_THISCALL);

	engine->RegisterObjectType("aabb", sizeof(AABB), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<AABB>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectType("physics_body", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_rigid_body", 0, asOBJ_REF);
	engine->RegisterObjectType("ray", sizeof(Ray), asOBJ_VALUE | asGetTypeTraits<Ray>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectType("raycast_info", sizeof(RaycastInfo), asOBJ_VALUE | asGetTypeTraits<RaycastInfo>());
	engine->RegisterObjectType("transform", sizeof(Transform), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Transform>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectType("vector", sizeof(Vector3), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Vector3>() | asOBJ_APP_CLASS_ALLFLOATS);

	engine->RegisterObjectType("physics_material", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_material", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_material", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_material", "float get_bounciness() const property", asMETHOD(Material, getBounciness), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "void set_bounciness(float bounciness) property", asMETHOD(Material, setBounciness), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "float get_friction_coefficient() const property", asMETHOD(Material, getFrictionCoefficient), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "void set_friction_coefficient(float friction_coefficient) property", asMETHOD(Material, setFrictionCoefficient), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "float get_friction_coefficient_sqrt() const property", asMETHOD(Material, getFrictionCoefficientSqrt), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "float get_mass_density() const property", asMETHOD(Material, getMassDensity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "void set_mass_density(float mass_density) property", asMETHOD(Material, setMassDensity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_material", "string opImplConv()", asMETHOD(Material, to_string), asCALL_THISCALL);

	RegisterCollisionShape<CollisionShape>(engine, "physics_collision_shape");
	engine->RegisterObjectType("physics_collider", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_collider", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_collider", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_collider", "physics_entity get_entity() const property", asMETHOD(Collider, getEntity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "physics_collision_shape@ get_collision_shape() property", asMETHODPR(Collider, getCollisionShape, (), CollisionShape*), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const physics_collision_shape@ get_collision_shape() const property", asMETHODPR(Collider, getCollisionShape, () const, const CollisionShape*), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "physics_body@ get_body() const property", asMETHOD(Collider, getBody), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const transform& get_local_to_body_transform() const property", asMETHOD(Collider, getLocalToBodyTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_local_to_body_transform(const transform&in transform) property", asMETHOD(Collider, setLocalToBodyTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const transform get_local_to_world_transform() const", asMETHOD(Collider, getLocalToWorldTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const aabb get_world_aabb() const property", asMETHOD(Collider, getWorldAABB), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "bool test_aabb_overlap(const aabb&in world_aabb) const", asMETHOD(Collider, testAABBOverlap), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "bool test_point_inside(const vector&in world_point)", asMETHOD(Collider, testPointInside), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "bool raycast(const ray&in ray, raycast_info& raycast_info)", asMETHOD(Collider, raycast), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "uint16 get_collide_with_mask() const property", asMETHOD(Collider, getCollideWithMaskBits), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_collide_with_mask(uint16 bits) property", asMETHOD(Collider, setCollideWithMaskBits), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "uint16 get_collision_category() const property", asMETHOD(Collider, getCollisionCategoryBits), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_collision_category(uint16 bits) property", asMETHOD(Collider, setCollisionCategoryBits), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "uint16 get_broad_phase_id() const property", asMETHOD(Collider, getBroadPhaseId), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "physics_material& get_material() property", asMETHOD(Collider, getMaterial), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_material(const physics_material&in material) property", asMETHOD(Collider, setMaterial), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "bool get_is_trigger() const property", asMETHOD(Collider, getIsTrigger), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_is_trigger(bool is_trigger) property", asMETHOD(Collider, setIsTrigger), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "bool get_is_simulation_collider() const property", asMETHOD(Collider, getIsSimulationCollider), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_is_simulation_collider(bool is_simulation_collider) property", asMETHOD(Collider, setIsSimulationCollider), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "bool get_is_world_query_collider() const property", asMETHOD(Collider, getIsWorldQueryCollider), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_is_world_query_collider(bool is_world_query_collider) property", asMETHOD(Collider, setIsWorldQueryCollider), asCALL_THISCALL);

	RegisterPhysicsBody<Body>(engine, "physics_body");
	RegisterPhysicsBody<RigidBody>(engine, "physics_rigid_body");
	engine->RegisterObjectMethod("physics_rigid_body", "float get_mass() const property", asMETHOD(RigidBody, getMass), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_mass(float mass) property", asMETHOD(RigidBody, setMass), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "vector get_linear_velocity() const property", asMETHOD(RigidBody, getLinearVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_linear_velocity(const vector&in linear_velocity) property", asMETHOD(RigidBody, setLinearVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "vector get_angular_velocity() const property", asMETHOD(RigidBody, getAngularVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_angular_velocity(const vector&in angular_velocity) property", asMETHOD(RigidBody, setAngularVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "const vector& get_local_inertia_tensor() const property", asMETHOD(RigidBody, getLocalInertiaTensor), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_local_inertia_tensor(const vector&in local_inertia_tensor) property", asMETHOD(RigidBody, setLocalInertiaTensor), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "const vector& get_local_center_of_mass() const property", asMETHOD(RigidBody, getLocalCenterOfMass), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_local_center_of_mass(const vector&in local_center_of_mass) property", asMETHOD(RigidBody, setLocalCenterOfMass), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void update_local_center_of_mass_from_colliders()", asMETHOD(RigidBody, updateLocalCenterOfMassFromColliders), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void update_local_inertia_tensor_from_colliders()", asMETHOD(RigidBody, updateLocalInertiaTensorFromColliders), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void update_mass_from_colliders()", asMETHOD(RigidBody, updateMassFromColliders), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void update_mass_properties_from_colliders()", asMETHOD(RigidBody, updateMassPropertiesFromColliders), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "physics_body_type get_type() const property", asMETHOD(RigidBody, getType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_type(physics_body_type type) property", asMETHOD(RigidBody, setType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "bool get_is_gravity_enabled() const property", asMETHOD(RigidBody, isGravityEnabled), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_is_gravity_enabled(bool enabled) property", asMETHOD(RigidBody, enableGravity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_is_sleeping(bool enabled)", asMETHOD(RigidBody, setIsSleeping), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "float get_linear_damping() const property", asMETHOD(RigidBody, getLinearDamping), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_linear_damping(float linear_damping) property", asMETHOD(RigidBody, setLinearDamping), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "float get_angular_damping() const property", asMETHOD(RigidBody, getAngularDamping), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_angular_damping(float angular_damping) property", asMETHOD(RigidBody, setAngularDamping), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "const vector& get_linear_lock_axis_factor() const property", asMETHOD(RigidBody, getLinearLockAxisFactor), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_linear_lock_axis_factor(const vector&in linear_lock_axis_factor) property", asMETHOD(RigidBody, setLinearLockAxisFactor), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "const vector& get_angular_lock_axis_factor() const property", asMETHOD(RigidBody, getAngularLockAxisFactor), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_rigid_body", "void set_angular_lock_axis_factor(const vector&in angular_lock_axis_factor) property", asMETHOD(RigidBody, setAngularLockAxisFactor), asCALL_THISCALL);

	engine->RegisterObjectType("physics_contact_point", sizeof(CollisionCallback::ContactPoint), asOBJ_VALUE | asGetTypeTraits<CollisionCallback::ContactPoint>());
	engine->RegisterObjectBehaviour("physics_contact_point", asBEHAVE_CONSTRUCT, "void f(const physics_contact_point&in point)", asFUNCTION((rp_construct<CollisionCallback::ContactPoint, const CollisionCallback::ContactPoint&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_contact_point", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<CollisionCallback::ContactPoint>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_contact_point", "const vector& get_world_normal() const property", asMETHOD(CollisionCallback::ContactPoint, getWorldNormal), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_point", "const vector& get_local_point_on_collider1() const property", asMETHOD(CollisionCallback::ContactPoint, getLocalPointOnCollider1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_point", "const vector& get_local_point_on_collider2() const property", asMETHOD(CollisionCallback::ContactPoint, getLocalPointOnCollider2), asCALL_THISCALL);
	engine->RegisterObjectType("physics_contact_pair", sizeof(CollisionCallback::ContactPair), asOBJ_VALUE | asGetTypeTraits<CollisionCallback::ContactPair>());
	engine->RegisterObjectBehaviour("physics_contact_pair", asBEHAVE_CONSTRUCT, "void f(const physics_contact_pair&in pair)", asFUNCTION((rp_construct<CollisionCallback::ContactPair, const CollisionCallback::ContactPair&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_contact_pair", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<CollisionCallback::ContactPair>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_contact_pair", "uint get_nb_contact_points() const property", asMETHOD(CollisionCallback::ContactPair, getNbContactPoints), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_contact_point get_contact_point(uint index) const", asMETHOD(CollisionCallback::ContactPair, getContactPoint), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_body& get_body1() const property", asMETHOD(CollisionCallback::ContactPair, getBody1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_body& get_body2() const property", asMETHOD(CollisionCallback::ContactPair, getBody2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_collider& get_collider1() const property", asMETHOD(CollisionCallback::ContactPair, getCollider1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_collider& get_collider2() const property", asMETHOD(CollisionCallback::ContactPair, getCollider2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_contact_event_type get_event_type() const property", asMETHOD(CollisionCallback::ContactPair, getEventType), asCALL_THISCALL);
	engine->RegisterObjectType("physics_collision_callback_data", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_collision_callback_data", "uint get_nb_contact_pairs() const property", asMETHOD(CollisionCallback::CallbackData, getNbContactPairs), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collision_callback_data", "physics_contact_pair get_contact_pair(uint64 index) const", asMETHOD(CollisionCallback::CallbackData, getContactPair), asCALL_THISCALL);
	engine->RegisterObjectType("physics_overlap_pair", sizeof(OverlapCallback::OverlapPair), asOBJ_VALUE | asGetTypeTraits<OverlapCallback::OverlapPair>());
	engine->RegisterObjectBehaviour("physics_overlap_pair", asBEHAVE_CONSTRUCT, "void f(const physics_overlap_pair&in pair)", asFUNCTION((rp_construct<OverlapCallback::OverlapPair, const OverlapCallback::OverlapPair&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_overlap_pair", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<OverlapCallback::OverlapPair>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_overlap_pair", "physics_body& get_body1() const property", asMETHOD(OverlapCallback::OverlapPair, getBody1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_overlap_pair", "physics_body& get_body2() const property", asMETHOD(OverlapCallback::OverlapPair, getBody2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_overlap_pair", "physics_collider& get_collider1() const property", asMETHOD(OverlapCallback::OverlapPair, getCollider1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_overlap_pair", "physics_collider& get_collider2() const property", asMETHOD(OverlapCallback::OverlapPair, getCollider2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_overlap_pair", "physics_overlap_event_type get_event_type() const property", asMETHOD(OverlapCallback::OverlapPair, getEventType), asCALL_THISCALL);
	engine->RegisterObjectType("physics_overlap_callback_data", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_overlap_callback_data", "uint get_nb_overlap_pairs() const property", asMETHOD(OverlapCallback::CallbackData, getNbOverlappingPairs), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_overlap_callback_data", "physics_overlap_pair get_overlapping_pair(uint index) const", asMETHOD(OverlapCallback::CallbackData, getOverlappingPair), asCALL_THISCALL);

	engine->RegisterEnum("physics_joint_type");
	engine->RegisterEnumValue("physics_joint_type", "BALL_SOCKET_JOINT", int(JointType::BALLSOCKETJOINT));
	engine->RegisterEnumValue("physics_joint_type", "SLIDER_JOINT", int(JointType::SLIDERJOINT));
	engine->RegisterEnumValue("physics_joint_type", "HINGE_JOINT", int(JointType::HINGEJOINT));
	engine->RegisterEnumValue("physics_joint_type", "FIXED_JOINT", int(JointType::FIXEDJOINT));
	engine->RegisterObjectType("physics_joint_info", sizeof(JointInfo), asOBJ_VALUE | asGetTypeTraits<JointInfo>());
	engine->RegisterObjectBehaviour("physics_joint_info", asBEHAVE_CONSTRUCT, "void f(physics_rigid_body@ body1, physics_rigid_body@ body2, physics_joint_type constraint_type)", asFUNCTION((rp_construct<JointInfo, RigidBody*, RigidBody*, JointType>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_joint_info", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<JointInfo>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_joint_info", "physics_rigid_body@ body1", asOFFSET(JointInfo, body1));
	engine->RegisterObjectProperty("physics_joint_info", "physics_rigid_body@ body2", asOFFSET(JointInfo, body2));
	engine->RegisterObjectProperty("physics_joint_info", "physics_joint_type type", asOFFSET(JointInfo, type));
	engine->RegisterObjectProperty("physics_joint_info", "physics_joints_position_correction_technique position_correction_technique", asOFFSET(JointInfo, positionCorrectionTechnique));
	engine->RegisterObjectProperty("physics_joint_info", "bool isCollisionEnabled", asOFFSET(JointInfo, isCollisionEnabled));
	engine->RegisterObjectType("physics_joint", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_joint", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_joint", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_joint", "physics_rigid_body@ get_body1() const property", asMETHOD(Joint, getBody1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "physics_rigid_body@ get_body2() const property", asMETHOD(Joint, getBody2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "physics_joint_type get_type() const property", asMETHOD(Joint, getType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "vector get_reaction_force(float time_step) const", asMETHOD(Joint, getReactionForce), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "vector get_reaction_torque(float time_step) const", asMETHOD(Joint, getReactionTorque), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "bool get_is_collision_enabled() const property", asMETHOD(Joint, isCollisionEnabled), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "physics_entity get_entity() const property", asMETHOD(Joint, getEntity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_joint", "string opImplConv()", asMETHOD(Joint, to_string), asCALL_THISCALL);

	engine->RegisterObjectBehaviour("vector", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<Vector3>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_CONSTRUCT, "void f(float x, float y, float z = 0.0f)", asFUNCTION((rp_construct<Vector3, decimal, decimal, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Vector3>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("vector", "float x", asOFFSET(Vector3, x));
	engine->RegisterObjectProperty("vector", "float y", asOFFSET(Vector3, y));
	engine->RegisterObjectProperty("vector", "float z", asOFFSET(Vector3, z));
	engine->RegisterObjectMethod("vector", "vector &opAddAssign(const vector &in)", asMETHODPR(Vector3, operator+=, (const Vector3&), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector &opSubAssign(const vector &in)", asMETHODPR(Vector3, operator-=, (const Vector3&), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector &opMulAssign(float)", asMETHODPR(Vector3, operator*=, (decimal), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector &opDivAssign(float)", asMETHODPR(Vector3, operator/=, (decimal), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool opEquals(const vector &in) const", asMETHODPR(Vector3, operator==, (const Vector3&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector opAdd(const vector &in) const", asFUNCTIONPR(operator+, (const Vector3&, const Vector3&), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opSub(const vector &in) const", asFUNCTIONPR(operator-, (const Vector3&, const Vector3&), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opMul(const vector &in) const", asFUNCTIONPR(operator*, (const Vector3&, const Vector3&), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opDiv(const vector &in) const", asFUNCTIONPR(operator/, (const Vector3&, const Vector3&), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opMul(float) const", asFUNCTIONPR(operator*, (const Vector3&, float), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opDiv(float) const", asFUNCTIONPR(operator/, (const Vector3&, float), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "void set(float x, float y, float z)", asMETHOD(Vector3, setAllValues), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void setToZero()", asMETHOD(Vector3, setToZero), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float length() const", asMETHOD(Vector3, length), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float length_square() const", asMETHOD(Vector3, lengthSquare), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool get_is_zero() const property", asMETHOD(Vector3, isZero), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool get_is_unit() const property", asMETHOD(Vector3, isUnit), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool get_is_finite() const property", asMETHOD(Vector3, isFinite), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float dot(const vector&in) const", asMETHOD(Vector3, dot), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector cross(const vector&in) const", asMETHOD(Vector3, cross), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "void normalize()", asMETHOD(Vector3, normalize), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector get_absolute() const property", asMETHOD(Vector3, getAbsoluteVector), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "int get_min_axis() const property", asMETHOD(Vector3, getMinAxis), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "int get_max_axis() const property", asMETHOD(Vector3, getMaxAxis), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float get_min_value() const property", asMETHOD(Vector3, getMinValue), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float get_max_value() const property", asMETHOD(Vector3, getMaxValue), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float& opIndex(int index)", asMETHODPR(Vector3, operator[], (int), float&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "const float& opIndex(int index) const", asMETHODPR(Vector3, operator[], (int) const, const float&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "string opImplConv() const", asMETHOD(Vector3, to_string), asCALL_THISCALL);

	engine->RegisterObjectBehaviour("ray", asBEHAVE_CONSTRUCT, "void f(const vector&in p1, const vector&in p2, float max_frac = 1.0f)", asFUNCTION((rp_construct<Ray, const Vector3&, const Vector3&, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ray", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Ray>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("ray", "vector point1", asOFFSET(Ray, point1));
	engine->RegisterObjectProperty("ray", "vector point2", asOFFSET(Ray, point2));
	engine->RegisterObjectProperty("ray", "float max_fraction", asOFFSET(Ray, maxFraction));
	engine->RegisterObjectBehaviour("raycast_info", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION((rp_construct<RaycastInfo>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("raycast_info", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<RaycastInfo>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("raycast_info", "vector world_point", asOFFSET(RaycastInfo, worldPoint));
	engine->RegisterObjectProperty("raycast_info", "vector world_normal", asOFFSET(RaycastInfo, worldNormal));
	engine->RegisterObjectProperty("raycast_info", "float hit_fraction", asOFFSET(RaycastInfo, hitFraction));
	engine->RegisterObjectProperty("raycast_info", "int triangle_index", asOFFSET(RaycastInfo, triangleIndex));
	engine->RegisterObjectProperty("raycast_info", "physics_body@ body", asOFFSET(RaycastInfo, body));
	engine->RegisterObjectProperty("raycast_info", "physics_collider@ collider", asOFFSET(RaycastInfo, collider));

	engine->RegisterObjectType("matrix3x3", sizeof(Matrix3x3), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Matrix3x3>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("matrix3x3", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<Matrix3x3>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("matrix3x3", asBEHAVE_CONSTRUCT, "void f(float value)", asFUNCTION((rp_construct<Matrix3x3, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("matrix3x3", asBEHAVE_CONSTRUCT, "void f(float a1, float a2, float a3, float b1, float b2, float b3, float c1, float c2, float c3)", asFUNCTION((rp_construct<Matrix3x3, decimal, decimal, decimal, decimal, decimal, decimal, decimal, decimal, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("matrix3x3", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Matrix3x3>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "void set(float a1, float a2, float a3, float b1, float b2, float b3, float c1, float c2, float c3)", asMETHOD(Matrix3x3, setAllValues), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "void set_to_zero()", asMETHOD(Matrix3x3, setToZero), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "void set_to_identity()", asMETHOD(Matrix3x3, setToIdentity), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "vector get_column(int i) const", asMETHOD(Matrix3x3, getColumn), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "vector get_row(int i) const", asMETHOD(Matrix3x3, getRow), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 get_transpose() const property", asMETHOD(Matrix3x3, getTranspose), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "float get_determinant() const property", asMETHOD(Matrix3x3, getDeterminant), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "float get_trace() const property", asMETHOD(Matrix3x3, getTrace), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 get_inverse() const property", asMETHODPR(Matrix3x3, getInverse, () const, Matrix3x3), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 get_inverse(float determinant) const", asMETHODPR(Matrix3x3, getInverse, (decimal) const, Matrix3x3), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 get_absolute() const property", asMETHOD(Matrix3x3, getAbsoluteMatrix), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 opAdd(const matrix3x3&in matrix) const", asFUNCTIONPR(operator+, (const Matrix3x3&, const Matrix3x3&), Matrix3x3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3& opAddAssign(const matrix3x3&in matrix)", asMETHOD(Matrix3x3, operator+=), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 opSub(const matrix3x3&in matrix) const", asFUNCTIONPR(operator-, (const Matrix3x3&, const Matrix3x3&), Matrix3x3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3& opSubAssign(const matrix3x3&in matrix)", asMETHOD(Matrix3x3, operator-=), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 opNeg() const", asFUNCTIONPR(operator-, (const Matrix3x3&), Matrix3x3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 opMul(const matrix3x3&in matrix) const", asFUNCTIONPR(operator*, (const Matrix3x3&, const Matrix3x3&), Matrix3x3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 opMul(float value) const", asFUNCTIONPR(operator*, (const Matrix3x3&, float), Matrix3x3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3 opMulR(float value) const", asFUNCTIONPR(operator*, (float, const Matrix3x3&), Matrix3x3), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("matrix3x3", "matrix3x3& opMulAssign(float value)", asMETHOD(Matrix3x3, operator*=), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "vector opMul(const vector&in value) const", asFUNCTIONPR(operator*, (const Matrix3x3&, const Vector3&), Vector3), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("matrix3x3", "bool opEquals(const matrix3x3&in)", asMETHOD(Matrix3x3, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "vector& opIndex(int row)", asMETHODPR(Matrix3x3, operator[], (int), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "const vector& opIndex(int row) const", asMETHODPR(Matrix3x3, operator[], (int) const, const Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("matrix3x3", "string opImplConv()", asMETHOD(Matrix3x3, to_string), asCALL_THISCALL);
	engine->RegisterGlobalFunction("matrix3x3 get_IDENTITY_MATRIX() property", asFUNCTION(Matrix3x3::identity), asCALL_CDECL);

	engine->RegisterObjectType("quaternion", sizeof(Quaternion), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Quaternion>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<Quaternion>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_CONSTRUCT, "void f(float x, float y, float  z, float w)", asFUNCTION((rp_construct<Quaternion, decimal, decimal, decimal, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("quaternion", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Quaternion>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("quaternion", "float x", asOFFSET(Quaternion, x));
	engine->RegisterObjectProperty("quaternion", "float y", asOFFSET(Quaternion, y));
	engine->RegisterObjectProperty("quaternion", "float z", asOFFSET(Quaternion, z));
	engine->RegisterObjectProperty("quaternion", "float w", asOFFSET(Quaternion, w));
	engine->RegisterObjectMethod("quaternion", "quaternion opAdd(const quaternion &in)", asMETHODPR(Quaternion, operator+, (const Quaternion&) const, Quaternion), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion &opAddAssign(const quaternion &in)", asMETHODPR(Quaternion, operator+=, (const Quaternion&), Quaternion&), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion opSub(const quaternion &in)", asMETHODPR(Quaternion, operator-, (const Quaternion&) const, Quaternion), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion &opSubAssign(const quaternion &in)", asMETHODPR(Quaternion, operator-=, (const Quaternion&), Quaternion&), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion opMul(const quaternion&in)", asMETHODPR(Quaternion, operator*, (const Quaternion&) const, Quaternion), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion opMul(float) const", asMETHODPR(Quaternion, operator*, (decimal) const, Quaternion), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "bool opEquals(const quaternion &in) const", asMETHODPR(Quaternion, operator==, (const Quaternion&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set(float x, float y, float z, float w)", asMETHOD(Quaternion, setAllValues), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set_to_zero()", asMETHOD(Quaternion, setToZero), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void set_to_identity()", asMETHOD(Quaternion, setToIdentity), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float length() const", asMETHOD(Quaternion, length), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float length_square() const", asMETHOD(Quaternion, lengthSquare), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "bool get_is_unit() const property", asMETHOD(Quaternion, isUnit), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "bool get_is_valid() const property", asMETHOD(Quaternion, isValid), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "bool get_is_finite() const property", asMETHOD(Quaternion, isFinite), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "float dot(const quaternion&in) const", asMETHOD(Quaternion, dot), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void normalize()", asMETHOD(Quaternion, normalize), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void inverse()", asMETHOD(Quaternion, inverse), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "vector get_v() const property", asMETHOD(Quaternion, getVectorV), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion get_unit() const property", asMETHOD(Quaternion, getUnit), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion get_conjugate() const property", asMETHOD(Quaternion, getConjugate), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "quaternion get_inversed() const property", asMETHOD(Quaternion, getInverse), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "void get_rotation_angle_axis(float&out angle, vector&out axis) const", asMETHOD(Quaternion, getRotationAngleAxis), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "matrix3x3 get_matrix() const property", asMETHOD(Quaternion, getMatrix), asCALL_THISCALL);
	engine->RegisterObjectMethod("quaternion", "string opImplConv() const", asMETHOD(Quaternion, to_string), asCALL_THISCALL);
	engine->RegisterGlobalFunction("quaternion get_IDENTITY_QUATERNION() property", asFUNCTION(Quaternion::identity), asCALL_CDECL);
	engine->RegisterGlobalFunction("quaternion quaternion_slerp(const quaternion& q1, const quaternion& q2, float t)", asFUNCTION(Quaternion::slerp), asCALL_CDECL);
	engine->RegisterGlobalFunction("quaternion quaternion_from_euler_angles(float angle_x, float angle_y, float angle_z)", asFUNCTIONPR(Quaternion::fromEulerAngles, (decimal, decimal, decimal), Quaternion), asCALL_CDECL);
	engine->RegisterGlobalFunction("quaternion quaternion_from_euler_angles(const vector& angles)", asFUNCTIONPR(Quaternion::fromEulerAngles, (const Vector3&), Quaternion), asCALL_CDECL);

	engine->RegisterObjectBehaviour("transform", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<Transform>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("transform", asBEHAVE_CONSTRUCT, "void f(const vector&in position, const matrix3x3&in orientation)", asFUNCTION((rp_construct<Transform, const Vector3&, const Matrix3x3&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("transform", asBEHAVE_CONSTRUCT, "void f(const vector&in position, const quaternion&in orientation)", asFUNCTION((rp_construct<Transform, const Vector3&, const Quaternion&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("transform", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Transform>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("transform", "const vector& get_position() const property", asMETHOD(Transform, getPosition), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "const quaternion& get_orientation() const property", asMETHOD(Transform, getOrientation), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "void set_position(const vector&in position) property", asMETHOD(Transform, setPosition), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "void set_orientation(const quaternion&in orientation) property", asMETHOD(Transform, setOrientation), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "void set_to_identity()", asMETHOD(Transform, setToIdentity), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "transform get_inverse() const property", asMETHOD(Transform, getInverse), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "bool get_is_valid() const property", asMETHOD(Transform, isValid), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "void set_from_opengl_matrix(float[]@ matrix)", asFUNCTION(transform_set_from_opengl_matrix), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("transform", "float[]@ get_opengl_matrix() const", asFUNCTION(transform_get_opengl_matrix), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("transform", "bool opEquals(const transform&in) const", asMETHOD(Transform, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "transform opMul(const transform&in) const", asMETHODPR(Transform, operator*, (const Transform&) const, Transform), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "vector opMul(const vector&in) const", asMETHODPR(Transform, operator*, (const Vector3&) const, Vector3), asCALL_THISCALL);
	engine->RegisterObjectMethod("transform", "string opImplConv()", asMETHOD(Transform, to_string), asCALL_THISCALL);
	engine->RegisterGlobalFunction("transform get_IDENTITY_TRANSFORM() property", asFUNCTION(Transform::identity), asCALL_CDECL);
	engine->RegisterGlobalFunction("transform transforms_interpolate()", asFUNCTION(Transform::interpolateTransforms), asCALL_CDECL);

	engine->RegisterObjectBehaviour("aabb", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<AABB>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_CONSTRUCT, "void f(const vector&in min, const vector&in max)", asFUNCTION((rp_construct<AABB, const Vector3&, const Vector3&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("aabb", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<AABB>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "vector get_center() const property", asMETHOD(AABB, getCenter), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "const vector& get_min() const property", asMETHOD(AABB, getMin), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "const vector& get_max() const property", asMETHOD(AABB, getMax), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void set_min(const vector&in min) property", asMETHOD(AABB, setMin), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void set_max(const vector&in max) property", asMETHOD(AABB, setMax), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "vector get_extent() const property", asMETHOD(AABB, getExtent), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void inflate(float x, float y, float z)", asMETHOD(AABB, inflate), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void inflate_with_point(const vector&in point)", asMETHOD(AABB, inflateWithPoint), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool test_collision(const aabb&in aabb) const", asMETHOD(AABB, testCollision), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void merge_with(const aabb&in aabb)", asMETHOD(AABB, mergeWithAABB), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void merge(const aabb&in aabb1, const aabb&in aabb2)", asMETHOD(AABB, mergeTwoAABBs), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool contains(const aabb&in aabb) const", asMETHODPR(AABB, contains, (const AABB&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool contains(const vector&in point, float epsilon = EPSILON) const", asMETHODPR(AABB, contains, (const Vector3&, decimal) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool test_collision_triangle_aabb(const vector[]@ points) const", asFUNCTION(aabb_test_collision_triangle), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("aabb", "float get_volume() const property", asMETHOD(AABB, getVolume), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "void apply_scale(const vector&in scale)", asMETHOD(AABB, applyScale), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool test_ray_intersect(const vector&in ray_origin, const vector&in ray_direction_inv, float ray_max_fraction)", asMETHOD(AABB, testRayIntersect), asCALL_THISCALL);
	engine->RegisterObjectMethod("aabb", "bool raycast(const ray&in ray, vector&out hit_point)", asMETHOD(AABB, raycast), asCALL_THISCALL);
	engine->RegisterGlobalFunction("aabb aabb_create_from_triangle(const vector[]@ points)", asFUNCTION(aabb_from_triangle), asCALL_CDECL);

	engine->RegisterObjectType("physics_world_settings", sizeof(PhysicsWorld::WorldSettings), asOBJ_VALUE | asGetTypeTraits<PhysicsWorld::WorldSettings>());
	engine->RegisterObjectBehaviour("physics_world_settings", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<PhysicsWorld::WorldSettings>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_world_settings", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<PhysicsWorld::WorldSettings>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_world_settings", "string world_name", asOFFSET(PhysicsWorld::WorldSettings, worldName));
	engine->RegisterObjectProperty("physics_world_settings", "vector gravity", asOFFSET(PhysicsWorld::WorldSettings, gravity));
	engine->RegisterObjectProperty("physics_world_settings", "float persistent_contact_distance_threshold", asOFFSET(PhysicsWorld::WorldSettings, persistentContactDistanceThreshold));
	engine->RegisterObjectProperty("physics_world_settings", "float default_friction_coefficient", asOFFSET(PhysicsWorld::WorldSettings, defaultFrictionCoefficient));
	engine->RegisterObjectProperty("physics_world_settings", "float default_bounciness", asOFFSET(PhysicsWorld::WorldSettings, defaultBounciness));
	engine->RegisterObjectProperty("physics_world_settings", "float restitution_velocity_threshold", asOFFSET(PhysicsWorld::WorldSettings, restitutionVelocityThreshold));
	engine->RegisterObjectProperty("physics_world_settings", "bool is_sleeping_enabled", asOFFSET(PhysicsWorld::WorldSettings, isSleepingEnabled));
	engine->RegisterObjectProperty("physics_world_settings", "uint16 default_velocity_solver_iterations_count", asOFFSET(PhysicsWorld::WorldSettings, defaultVelocitySolverNbIterations));
	engine->RegisterObjectProperty("physics_world_settings", "uint16 default_position_solver_iterations_count", asOFFSET(PhysicsWorld::WorldSettings, defaultPositionSolverNbIterations));
	engine->RegisterObjectProperty("physics_world_settings", "float default_time_before_sleep", asOFFSET(PhysicsWorld::WorldSettings, defaultTimeBeforeSleep));
	engine->RegisterObjectProperty("physics_world_settings", "float default_sleep_linear_velocity", asOFFSET(PhysicsWorld::WorldSettings, defaultSleepLinearVelocity));
	engine->RegisterObjectProperty("physics_world_settings", "float default_sleep_angular_velocity", asOFFSET(PhysicsWorld::WorldSettings, defaultSleepAngularVelocity));
	engine->RegisterObjectProperty("physics_world_settings", "float cos_angle_similar_contact_manifold", asOFFSET(PhysicsWorld::WorldSettings, cosAngleSimilarContactManifold));
	engine->RegisterObjectMethod("physics_world_settings", "string opImplConv()", asMETHOD(PhysicsWorld::WorldSettings, to_string), asCALL_THISCALL);

	engine->RegisterFuncdef("float physics_raycast_callback(const raycast_info&in info)");
	engine->RegisterFuncdef("void physics_collision_callback(const physics_collision_callback_data& data)");
	engine->RegisterFuncdef("void physics_overlap_callback(const physics_overlap_callback_data& data)");
	engine->RegisterObjectType("physics_world", 0, asOBJ_REF);
	engine->RegisterGlobalFunction("void physics_world_destroy(physics_world& world)", asFUNCTION(world_destroy), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_FACTORY, "physics_world@ w(const physics_world_settings&in world_settings)", asMETHOD(PhysicsCommon, createPhysicsWorld), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world_settings", "bool test_overlap(physics_body& body1, physics_body& body2)", asMETHODPR(PhysicsWorld, testOverlap, (Body*, Body*), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void raycast(const ray&in ray, physics_raycast_callback@ callback, uint16 category_mask = 0xffff)", asFUNCTION(world_raycast), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "bool test_overlap(physics_body@ body1, physics_body@ body2)", asMETHODPR(PhysicsWorld, testOverlap, (Body*, Body*), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void test_overlap(physics_body@ body, physics_overlap_callback@ callback)", asFUNCTION(world_test_overlap_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void test_overlap(physics_overlap_callback@ callback)", asFUNCTION(world_test_overlap), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void test_collision(physics_body@ body1, physics_body@ body2, physics_collision_callback@ callback)", asFUNCTION(world_test_collision_bodies), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void test_collision(physics_body@ body, physics_collision_callback@ callback)", asFUNCTION(world_test_collision_body), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "void test_collision(physics_collision_callback@ callback)", asFUNCTION(world_test_collision), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "aabb get_world_aabb(const physics_collider@ collider) const", asMETHOD(PhysicsWorld, getWorldAABB), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "const string& get_name() const property", asMETHOD(PhysicsWorld, getName), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void update(float time_step)", asMETHOD(PhysicsWorld, update), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "uint16 get_nb_iterations_velocity_solver() const property", asMETHOD(PhysicsWorld, getNbIterationsVelocitySolver), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_nb_iterations_velocity_solver(uint16 iterations) property", asMETHOD(PhysicsWorld, setNbIterationsVelocitySolver), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "uint16 get_nb_iterations_position_solver() const property", asMETHOD(PhysicsWorld, getNbIterationsPositionSolver), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_nb_iterations_position_solver(uint16 iterations) property", asMETHOD(PhysicsWorld, setNbIterationsPositionSolver), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_contacts_position_correction_technique(physics_contact_position_correction_technique technique) property", asMETHOD(PhysicsWorld, setContactsPositionCorrectionTechnique), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "physics_rigid_body@ create_rigid_body(const transform&in transform)", asMETHOD(PhysicsWorld, createRigidBody), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void destroy_rigid_body(physics_rigid_body& body)", asMETHOD(PhysicsWorld, destroyRigidBody), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "physics_joint@ create_joint(const physics_joint_info&in joint_info)", asMETHOD(PhysicsWorld, createJoint), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void destroy_joint(physics_joint& joint)", asMETHOD(PhysicsWorld, destroyJoint), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "vector get_gravity() const property", asMETHOD(PhysicsWorld, getGravity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_gravity(const vector&in gravity) property", asMETHOD(PhysicsWorld, setGravity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "bool get_is_gravity_enabled() const property", asMETHOD(PhysicsWorld, isGravityEnabled), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_is_gravity_enabled(bool enabled) property", asMETHOD(PhysicsWorld, setIsGravityEnabled), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "bool get_is_sleeping_enabled() const property", asMETHOD(PhysicsWorld, isSleepingEnabled), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_is_sleeping_enabled(bool enabled) property", asMETHOD(PhysicsWorld, enableSleeping), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "float get_sleep_linear_velocity() const property", asMETHOD(PhysicsWorld, getSleepLinearVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_sleep_linear_velocity(float sleep_linear_velocity) property", asMETHOD(PhysicsWorld, setSleepLinearVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "float get_sleep_angular_velocity() const property", asMETHOD(PhysicsWorld, getSleepAngularVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_sleep_angular_velocity(float sleep_angular_velocity) property", asMETHOD(PhysicsWorld, setSleepAngularVelocity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "float get_time_before_sleep() const property", asMETHOD(PhysicsWorld, getTimeBeforeSleep), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_time_before_sleep(float time_before_sleep) property", asMETHOD(PhysicsWorld, setTimeBeforeSleep), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void set_callbacks(physics_collision_callback@ collision_callback, physics_overlap_callback@ trigger_callback)", asFUNCTION(world_set_callbacks), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "uint get_nb_rigid_bodies() const property", asMETHOD(PhysicsWorld, getNbRigidBodies), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "const physics_rigid_body& get_rigid_body(uint index) const", asMETHODPR(PhysicsWorld, getRigidBody, (uint32) const, const RigidBody*), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "physics_rigid_body& get_rigid_body(uint index)", asMETHODPR(PhysicsWorld, getRigidBody, (uint32), RigidBody*), asCALL_THISCALL);

	engine->RegisterObjectType("physics_half_edge_structure_edge", sizeof(HalfEdgeStructure::Edge), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<HalfEdgeStructure::Edge>());
	engine->RegisterObjectBehaviour("physics_half_edge_structure_edge", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<HalfEdgeStructure::Edge>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_half_edge_structure_edge", "uint vertex_index", asOFFSET(HalfEdgeStructure::Edge, vertexIndex));
	engine->RegisterObjectProperty("physics_half_edge_structure_edge", "uint twin_edge_index", asOFFSET(HalfEdgeStructure::Edge, twinEdgeIndex));
	engine->RegisterObjectProperty("physics_half_edge_structure_edge", "uint face_index", asOFFSET(HalfEdgeStructure::Edge, faceIndex));
	engine->RegisterObjectProperty("physics_half_edge_structure_edge", "uint next_edge_index", asOFFSET(HalfEdgeStructure::Edge, nextEdgeIndex));

	engine->RegisterObjectType("physics_half_edge_structure_face", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_half_edge_structure_face", "void set_face_vertices(uint[]@ face_vertices)", asFUNCTION(face_set_vertices), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_half_edge_structure_face", "uint[]@ get_face_vertices() const", asFUNCTION(face_get_vertices), asCALL_CDECL_OBJFIRST);

	engine->RegisterObjectType("physics_half_edge_structure_vertex", sizeof(HalfEdgeStructure::Vertex), asOBJ_VALUE | asGetTypeTraits<HalfEdgeStructure::Vertex>());
	engine->RegisterObjectBehaviour("physics_half_edge_structure_vertex", asBEHAVE_CONSTRUCT, "void f(uint vertex_coords_index)", asFUNCTION((rp_construct<HalfEdgeStructure::Vertex, uint32>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_half_edge_structure_vertex", asBEHAVE_DESTRUCT, "void f()", asFUNCTION((rp_destruct<HalfEdgeStructure::Vertex>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_half_edge_structure_vertex", "uint vertex_point_index", asOFFSET(HalfEdgeStructure::Vertex, vertexPointIndex));
	engine->RegisterObjectProperty("physics_half_edge_structure_vertex", "uint vertex_edge_index", asOFFSET(HalfEdgeStructure::Vertex, edgeIndex));

	engine->RegisterObjectType("physics_half_edge_structure", 0, asOBJ_REF|asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_half_edge_structure", "void compute_half_edges()", asMETHOD(HalfEdgeStructure, computeHalfEdges), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint add_vertex(uint vertex_point_index)", asMETHOD(HalfEdgeStructure, addVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint get_nb_faces() const property", asMETHOD(HalfEdgeStructure, getNbFaces), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint get_nb_half_edges() const property", asMETHOD(HalfEdgeStructure, getNbHalfEdges), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint get_nb_vertices() const property", asMETHOD(HalfEdgeStructure, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "const physics_half_edge_structure_face& get_face(uint index) const property", asMETHOD(HalfEdgeStructure, getFace), asCALL_THISCALL);


	RegisterConvexShape<CapsuleShape>(engine, "physics_capsule_shape");
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_radius() const property", asMETHOD(CapsuleShape, getRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "void set_radius(float radius) property", asMETHOD(CapsuleShape, setRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_height() const property", asMETHOD(CapsuleShape, getHeight), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "void set_height(float height) property", asMETHOD(CapsuleShape, setHeight), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "string opImplConv()", asMETHOD(CapsuleShape, to_string), asCALL_THISCALL);
	
	RegisterConvexShape<SphereShape>(engine, "physics_sphere_shape");
	engine->RegisterObjectMethod("physics_sphere_shape", "float get_radius() const property", asMETHOD(SphereShape, getRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_sphere_shape", "void set_radius(float radius) property", asMETHOD(SphereShape, setRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_sphere_shape", "string opImplConv()", asMETHOD(SphereShape, to_string), asCALL_THISCALL);

	RegisterConvexPolyhedronShape<BoxShape>(engine, "physics_box_shape");
	engine->RegisterObjectMethod("physics_box_shape", "vector& get_half_extents() const property", asMETHOD(BoxShape, getHalfExtents), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_box_shape", "void set_half_extents(const vector&in half_extents) property", asMETHOD(BoxShape, setHalfExtents), asCALL_THISCALL);

	RegisterConvexPolyhedronShape<TriangleShape>(engine, "physics_triangle_shape");
	engine->RegisterObjectMethod("physics_triangle_shape", "physics_triangle_raycast_side get_raycast_test_type() const property", asMETHOD(TriangleShape, getRaycastTestType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_shape", "void set_raycast_test_type(physics_triangle_raycast_side test_type) const property", asMETHOD(TriangleShape, setRaycastTestType), asCALL_THISCALL);
	engine->RegisterGlobalFunction("void physics_triangle_shape_compute_smooth_triangle_mesh_contact(const physics_collision_shape &in shape1, const physics_collision_shape &in shape2, vector & local_contact_point_shape1, vector & local_contact_point_shape2, const transform &in shape1_to_world, const transform &in shape2_to_world, float penitration_depth, vector & out_smooth_vertex_normal)", asFUNCTION(TriangleShape::computeSmoothTriangleMeshContact), asCALL_CDECL);

	engine->RegisterObjectType("physics_message", sizeof(Message), asOBJ_VALUE | asGetTypeTraits<Message>());
	engine->RegisterObjectBehaviour("physics_message", asBEHAVE_CONSTRUCT, "void f(string text, type=PHYSICS_MESSAGE_ERROR)", asFUNCTION((rp_construct<Message, std::string, Message::Type>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_message", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Message>), asCALL_CDECL_OBJFIRST);
	engine->RegisterEnum("physics_message_type");
	engine->RegisterEnumValue("physics_message_type", "PHYSICS_MESSAGE_ERROR", int(Message::Type::Error));
	engine->RegisterEnumValue("physics_message_type", "PHYSICS_MESSAGE_WARNING", int(Message::Type::Warning));
	engine->RegisterEnumValue("physics_message_type", "PHYSICS_MESSAGE_INFORMATION", int(Message::Type::Information));
	engine->RegisterObjectProperty("physics_message", "string text", asOFFSET(Message, text));
	engine->RegisterObjectProperty("physics_message", "physics_message_type", asOFFSET(Message, type));
	
	engine->RegisterObjectType("physics_height_field", sizeof(HeightField), asOBJ_VALUE | asGetTypeTraits<HeightField>());
	engine->RegisterEnum("physics_height_data_type");
	engine->RegisterEnumValue("physics_height_data_type", "PHYSICS_HEIGHT_FLOAT_TYPE", int(HeightField::HeightDataType::HEIGHT_FLOAT_TYPE));
	engine->RegisterEnumValue("physics_height_data_type", "PHYSICS_HEIGHT_DOUBLE_TYPE", int(HeightField::HeightDataType::HEIGHT_DOUBLE_TYPE));
	engine->RegisterEnumValue("physics_height_data_type", "PHYSICS_HEIGHT_INT_TYPE", int(HeightField::HeightDataType::HEIGHT_INT_TYPE));
	engine->RegisterObjectMethod("physics_height_field", "uint get_nb_rows() const property", asMETHOD(HeightField, getNbRows), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "uint get_nb_columns() const property", asMETHOD(HeightField, getNbColumns), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "float get_min_height() const property", asMETHOD(HeightField, getMinHeight), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "float get_max_height() const property", asMETHOD(HeightField, getMaxHeight), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "float get_integer_height_scale() const property", asMETHOD(HeightField, getIntegerHeightScale), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "vector get_vertex_at(uint x, uint y) const", asMETHOD(HeightField, getVertexAt), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "float get_height_at(uint x, uint y) const", asMETHOD(HeightField, getHeightAt), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "physics_height_data_type get_height_data_type() const property", asMETHOD(HeightField, getHeightDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "aabb& get_bounds() const property", asMETHOD(HeightField, getBounds), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field", "string opImplConv() const", asMETHOD(HeightField, to_string), asCALL_THISCALL);

	RegisterConcaveShape<HeightFieldShape>(engine, "physics_height_field_shape");
	engine->RegisterObjectMethod("physics_height_field_shape", "physics_height_field@ get_height_field() const property", asMETHOD(HeightFieldShape, getHeightField), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field_shape", "vector get_vertex_at(uint x, uint y) const", asMETHOD(HeightFieldShape, getVertexAt), asCALL_THISCALL);

	engine->RegisterObjectType("physics_convex_mesh", sizeof(ConvexMesh), asOBJ_VALUE | asGetTypeTraits<ConvexMesh>());
	engine->RegisterObjectMethod("physics_convex_mesh", "uint get_nb_vertices() const property", asMETHOD(ConvexMesh, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "vector& get_vertex(uint index) const", asMETHOD(ConvexMesh, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "uint get_nb_faces() const property", asMETHOD(ConvexMesh, getNbFaces), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "vector& get_face_normal(uint index) const", asMETHOD(ConvexMesh, getFaceNormal), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "physics_half_structure& get_half_edge_structure() const property", asMETHOD(ConvexMesh, getHalfEdgeStructure), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "vector& get_centroid() const property", asMETHOD(ConvexMesh, getCentroid), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "aabb& get_bounds() const property", asMETHOD(ConvexMesh, getBounds), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "float get_volume() const property", asMETHOD(ConvexMesh, getVolume), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "vector& get_local_inertia_tensor(float mass, vector scale) const", asMETHOD(ConvexMesh, getLocalInertiaTensor), asCALL_THISCALL);

	RegisterConvexPolyhedronShape<ConvexMeshShape>(engine, "physics_convex_mesh_shape");
	engine->RegisterObjectMethod("physics_convex_mesh_shape", "vector& get_scale() const property", asMETHOD(ConvexMeshShape, getScale), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh_shape", "void set_scale(vector& scale) const property", asMETHOD(ConvexMeshShape, setScale), asCALL_THISCALL);



}
