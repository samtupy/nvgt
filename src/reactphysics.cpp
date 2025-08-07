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

#include <string>
#include <unordered_map>
#include <vector>
#include <angelscript.h>
#include <reactphysics3d/reactphysics3d.h>
#include <scriptany.h>
#include <scriptarray.h>
#include "nvgt.h"
#include "nvgt_angelscript.h"
#include "reactphysics.h"

using namespace std;
using namespace reactphysics3d;

class event_listener;

PhysicsCommon g_physics;
unordered_map<PhysicsWorld*, event_listener*> g_physics_event_listeners;  // These need to be kept alive while the world exists, and the PhysicsWorld class has no user data.

// Angelscript factories.
template <class T, typename... A>
void rp_construct(void* mem, A... args) { new (mem) T(args...); }

template <class T>
void rp_copy_construct(void* mem, const T& obj) { new (mem) T(obj); }

template <class T>
void rp_destruct(T* obj) { obj->~T(); }

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

CollisionCallback::ContactPoint contact_pair_get_contact_point(const CollisionCallback::ContactPair& pair, uint32 index) {
	return pair.getContactPoint(index);
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
		if (new_context)
			g_ScriptEngine->ReturnContext(ctx);
		else
			ctx->PopState();
		return;
	}
	ctx->SetArgObject(0, (void*)data);
	ctx->Execute();
	if (new_context)
		g_ScriptEngine->ReturnContext(ctx);
	else
		ctx->PopState();
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
			if (new_context)
				g_ScriptEngine->ReturnContext(ctx);
			else
				ctx->PopState();
			return 0;
		}
		ctx->SetArgObject(0, (void*)&info);
		if (ctx->Execute() != asEXECUTION_FINISHED) {
			if (new_context)
				g_ScriptEngine->ReturnContext(ctx);
			else
				ctx->PopState();
			return 0;
		}
		float v = ctx->GetReturnFloat();
		if (new_context)
			g_ScriptEngine->ReturnContext(ctx);
		else
			ctx->PopState();
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

// World-related wrapper functions
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
	if (l->on_contact_callback) l->on_contact_callback->Release();
	if (l->on_overlap_callback) l->on_overlap_callback->Release();
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

// Shape destruction functions
void sphere_shape_destroy(SphereShape* shape) {
	g_physics.destroySphereShape(shape);
}

void box_shape_destroy(BoxShape* shape) {
	g_physics.destroyBoxShape(shape);
}

void capsule_shape_destroy(CapsuleShape* shape) {
	g_physics.destroyCapsuleShape(shape);
}

void convex_mesh_shape_destroy(ConvexMeshShape* shape) {
	g_physics.destroyConvexMeshShape(shape);
}

void height_field_shape_destroy(HeightFieldShape* shape) {
	g_physics.destroyHeightFieldShape(shape);
}

void concave_mesh_shape_destroy(ConcaveMeshShape* shape) {
	g_physics.destroyConcaveMeshShape(shape);
}

void convex_mesh_destroy(ConvexMesh* mesh) {
	g_physics.destroyConvexMesh(mesh);
}

void triangle_mesh_destroy(TriangleMesh* mesh) {
	g_physics.destroyTriangleMesh(mesh);
}

void height_field_destroy(HeightField* heightField) {
	g_physics.destroyHeightField(heightField);
}

void default_logger_destroy(DefaultLogger* logger) {
	g_physics.destroyDefaultLogger(logger);
}

/**
 * Unified collision shape destroyer that automatically dispatches to the
 * correct destroy function based on the shape's runtime type information.
 * This eliminates the need for users to know the specific shape type when
 * destroying shapes.
*/
void physics_shape_destroy(CollisionShape* shape) {
	if (!shape)
		return;
	// First dispatch on the broad shape type
	CollisionShapeType shapeType = shape->getType();
	switch (shapeType) {
		case CollisionShapeType::SPHERE: {
			SphereShape* sphereShape = static_cast<SphereShape*>(shape);
			sphere_shape_destroy(sphereShape);
			break;
		}
		case CollisionShapeType::CONVEX_POLYHEDRON: {
			// Convex polyhedrons need further disambiguation by name
			// We do not include triangle here; mainly because rp3d does not offer the function to destroy them
			CollisionShapeName shapeName = shape->getName();
			switch (shapeName) {
				case CollisionShapeName::BOX: {
					BoxShape* boxShape = static_cast<BoxShape*>(shape);
					box_shape_destroy(boxShape);
					break;
				}
				case CollisionShapeName::CAPSULE: {
					CapsuleShape* capsuleShape = static_cast<CapsuleShape*>(shape);
					capsule_shape_destroy(capsuleShape);
					break;
				}
				case CollisionShapeName::CONVEX_MESH: {
					ConvexMeshShape* convexMeshShape = static_cast<ConvexMeshShape*>(shape);
					convex_mesh_shape_destroy(convexMeshShape);
					break;
				}
				default: {
					std::string errorMsg = "Unknown convex polyhedron shape name: " +
					                       std::to_string(static_cast<int>(shapeName));
					throw std::runtime_error(errorMsg);
				}
			}
			break;
		}
		case CollisionShapeType::CONCAVE_SHAPE: {
			// Concave shapes also need disambiguation by name
			CollisionShapeName shapeName = shape->getName();
			switch (shapeName) {
				case CollisionShapeName::TRIANGLE_MESH: {
					ConcaveMeshShape* concaveShape = static_cast<ConcaveMeshShape*>(shape);
					concave_mesh_shape_destroy(concaveShape);
					break;
				}
				case CollisionShapeName::HEIGHTFIELD: {
					HeightFieldShape* heightFieldShape = static_cast<HeightFieldShape*>(shape);
					height_field_shape_destroy(heightFieldShape);
					break;
				}
				default: {
					std::string errorMsg = "Unknown concave shape name: " +
					                       std::to_string(static_cast<int>(shapeName));
					throw std::runtime_error(errorMsg);
				}
			}
			break;
		}
		default: {
			std::string errorMsg = "Unknown collision shape type: " +
			                       std::to_string(static_cast<int>(shapeType));
			throw std::runtime_error(errorMsg);
		}
	}
}

// Half-edge structure helper functions
CScriptArray* face_get_vertices(const HalfEdgeStructure::Face& f) {
	CScriptArray* array = CScriptArray::Create(get_array_type("array<uint>"), f.faceVertices.size());
	memcpy(array->GetBuffer(), &f.faceVertices[0], f.faceVertices.size() * sizeof(uint32));
	return array;
}

void face_set_vertices(HalfEdgeStructure::Face& f, CScriptArray* array) {
	f.faceVertices.clear();
	f.faceVertices.reserve(array->GetSize());
	memcpy(&f.faceVertices[0], array->GetBuffer(), array->GetSize() * sizeof(uint32));
}

struct ManagedTriangleData {
	std::vector<float> vertices;
	std::vector<uint32> indices;
	std::vector<float> normals;
	TriangleVertexArray* array;
	bool hasNormals;

	ManagedTriangleData() : array(nullptr), hasNormals(false) {}
	~ManagedTriangleData() { delete array; }
};

struct ManagedPolygonData {
	std::vector<float> vertices;
	std::vector<uint32> indices;
	std::vector<PolygonVertexArray::PolygonFace> faces;
	PolygonVertexArray* array;

	ManagedPolygonData() : array(nullptr) {}
	~ManagedPolygonData() { delete array; }
};

struct ManagedVertexData {
	std::vector<float> vertices;
	VertexArray* array;

	ManagedVertexData() : array(nullptr) {}
	~ManagedVertexData() { delete array; }
};

ManagedTriangleData* create_triangle_data(CScriptArray* verticesArray, CScriptArray* indicesArray) {
	if (verticesArray->GetSize() % 3 != 0)
		throw std::runtime_error("Vertices array size must be multiple of 3 (x,y,z components)");
	if (indicesArray->GetSize() % 3 != 0)
		throw std::runtime_error("Indices array size must be multiple of 3 (triangle indices)");
	auto* managed = new ManagedTriangleData();
	managed->vertices.resize(verticesArray->GetSize());
	for (uint32 i = 0; i < verticesArray->GetSize(); i++)
		managed->vertices[i] = *(float*)verticesArray->At(i);
	managed->indices.resize(indicesArray->GetSize());
	for (uint32 i = 0; i < indicesArray->GetSize(); i++)
		managed->indices[i] = *(uint32*)indicesArray->At(i);
	uint32 nbVertices = managed->vertices.size() / 3;
	uint32 nbTriangles = managed->indices.size() / 3;
	managed->array = new TriangleVertexArray(
	    nbVertices,
	    managed->vertices.data(),
	    3 * sizeof(float),  // stride for 3 floats (x,y,z)
	    nbTriangles,
	    managed->indices.data(),
	    3 * sizeof(uint32),  // stride for 3 indices
	    TriangleVertexArray::VertexDataType::VERTEX_FLOAT_TYPE,
	    TriangleVertexArray::IndexDataType::INDEX_INTEGER_TYPE);
	return managed;
}

ManagedTriangleData* create_triangle_data_with_normals(CScriptArray* verticesArray, CScriptArray* normalsArray, CScriptArray* indicesArray) {
	if (verticesArray->GetSize() % 3 != 0 || normalsArray->GetSize() % 3 != 0)
		throw std::runtime_error("Vertices and normals arrays size must be multiple of 3 (x,y,z components)");
	if (verticesArray->GetSize() != normalsArray->GetSize())
		throw std::runtime_error("Vertices and normals arrays must have same size");
	if (indicesArray->GetSize() % 3 != 0)
		throw std::runtime_error("Indices array size must be multiple of 3 (triangle indices)");
	auto* managed = new ManagedTriangleData();
	managed->hasNormals = true;
	managed->vertices.resize(verticesArray->GetSize());
	for (uint32 i = 0; i < verticesArray->GetSize(); i++)
		managed->vertices[i] = *(float*)verticesArray->At(i);
	managed->normals.resize(normalsArray->GetSize());
	for (uint32 i = 0; i < normalsArray->GetSize(); i++)
		managed->normals[i] = *(float*)normalsArray->At(i);
	managed->indices.resize(indicesArray->GetSize());
	for (uint32 i = 0; i < indicesArray->GetSize(); i++)
		managed->indices[i] = *(uint32*)indicesArray->At(i);
	uint32 nbVertices = managed->vertices.size() / 3;
	uint32 nbTriangles = managed->indices.size() / 3;
	managed->array = new TriangleVertexArray(
	    nbVertices,
	    managed->vertices.data(),
	    3 * sizeof(float),  // stride for 3 floats (x,y,z)
	    managed->normals.data(),
	    3 * sizeof(float),  // normals stride
	    nbTriangles,
	    managed->indices.data(),
	    3 * sizeof(uint32),  // stride for 3 indices
	    TriangleVertexArray::VertexDataType::VERTEX_FLOAT_TYPE,
	    TriangleVertexArray::NormalDataType::NORMAL_FLOAT_TYPE,
	    TriangleVertexArray::IndexDataType::INDEX_INTEGER_TYPE);
	return managed;
}

ManagedVertexData* create_vertex_data(CScriptArray* verticesArray) {
	if (verticesArray->GetSize() % 3 != 0)
		throw std::runtime_error("Vertices array size must be multiple of 3 (x,y,z components)");
	auto* managed = new ManagedVertexData();
	managed->vertices.resize(verticesArray->GetSize());
	for (uint32 i = 0; i < verticesArray->GetSize(); i++)
		managed->vertices[i] = *(float*)verticesArray->At(i);
	uint32 nbVertices = managed->vertices.size() / 3;
	managed->array = new VertexArray(
	    managed->vertices.data(),
	    3 * sizeof(float),  // stride for 3 floats (x,y,z)
	    nbVertices,
	    VertexArray::DataType::VERTEX_FLOAT_TYPE);
	return managed;
}

ManagedPolygonData* create_polygon_data(CScriptArray* verticesArray, CScriptArray* facesArray) {
	if (verticesArray->GetSize() % 3 != 0)
		throw std::runtime_error("Vertices array size must be multiple of 3 (x,y,z components)");
	auto* managed = new ManagedPolygonData();
	managed->vertices.resize(verticesArray->GetSize());
	for (uint32 i = 0; i < verticesArray->GetSize(); i++)
		managed->vertices[i] = *(float*)verticesArray->At(i);
	// Process faces array (array of arrays)
	uint32 totalIndices = 0;
	// First pass: count total indices needed
	for (uint32 faceIdx = 0; faceIdx < facesArray->GetSize(); faceIdx++) {
		CScriptArray* faceIndices = (CScriptArray*)facesArray->At(faceIdx);
		if (!faceIndices)
			throw std::runtime_error("Face array contains null face at index " + std::to_string(faceIdx));
		if (faceIndices->GetSize() < 3)
			throw std::runtime_error("Face " + std::to_string(faceIdx) + " must have at least 3 vertices");
		totalIndices += faceIndices->GetSize();
	}
	// Reserve space
	managed->indices.reserve(totalIndices);
	managed->faces.reserve(facesArray->GetSize());
	// Second pass: build indices array and face descriptors
	uint32 currentIndexBase = 0;
	for (uint32 faceIdx = 0; faceIdx < facesArray->GetSize(); faceIdx++) {
		CScriptArray* faceIndices = (CScriptArray*)facesArray->At(faceIdx);
		PolygonVertexArray::PolygonFace face;
		face.nbVertices = faceIndices->GetSize();
		face.indexBase = currentIndexBase;
		managed->faces.push_back(face);
		for (uint32 vertIdx = 0; vertIdx < faceIndices->GetSize(); vertIdx++) {
			uint32 vertexIndex = *(uint32*)faceIndices->At(vertIdx);
			managed->indices.push_back(vertexIndex);
		}
		currentIndexBase += faceIndices->GetSize();
	}
	uint32 nbVertices = managed->vertices.size() / 3;
	uint32 nbFaces = managed->faces.size();
	managed->array = new PolygonVertexArray(
	    nbVertices,
	    managed->vertices.data(),
	    3 * sizeof(float),  // stride for 3 floats (x,y,z)
	    managed->indices.data(),
	    sizeof(uint32),  // stride for indices
	    nbFaces,
	    managed->faces.data(),
	    PolygonVertexArray::VertexDataType::VERTEX_FLOAT_TYPE,
	    PolygonVertexArray::IndexDataType::INDEX_INTEGER_TYPE);
	return managed;
}

void triangle_vertex_array_get_triangle_vertices_indices(const TriangleVertexArray& array, uint32 triangleIndex, uint32& outV1Index, uint32& outV2Index, uint32& outV3Index) {
	array.getTriangleVerticesIndices(triangleIndex, outV1Index, outV2Index, outV3Index);
}

void triangle_mesh_get_triangle_vertices_indices(const TriangleMesh& mesh, uint32 triangleIndex, uint32& outV1Index, uint32& outV2Index, uint32& outV3Index) {
	mesh.getTriangleVerticesIndices(triangleIndex, outV1Index, outV2Index, outV3Index);
}

void triangle_mesh_get_triangle_vertices(const TriangleMesh& mesh, uint32 triangleIndex, Vector3& outV1, Vector3& outV2, Vector3& outV3) {
	mesh.getTriangleVertices(triangleIndex, outV1, outV2, outV3);
}

void triangle_mesh_get_triangle_vertices_normals(const TriangleMesh& mesh, uint32 triangleIndex, Vector3& outN1, Vector3& outN2, Vector3& outN3) {
	mesh.getTriangleVerticesNormals(triangleIndex, outN1, outN2, outN3);
}

void concave_mesh_shape_get_triangle_vertices_indices(const ConcaveMeshShape& shape, uint32 triangleIndex, uint32& outV1Index, uint32& outV2Index, uint32& outV3Index) {
	shape.getTriangleVerticesIndices(triangleIndex, outV1Index, outV2Index, outV3Index);
}

void concave_mesh_shape_get_triangle_vertices(const ConcaveMeshShape& shape, uint32 triangleIndex, Vector3& outV1, Vector3& outV2, Vector3& outV3) {
	shape.getTriangleVertices(triangleIndex, outV1, outV2, outV3);
}

void concave_mesh_shape_get_triangle_vertices_normals(const ConcaveMeshShape& shape, uint32 triangleIndex, Vector3& outN1, Vector3& outN2, Vector3& outN3) {
	shape.getTriangleVerticesNormals(triangleIndex, outN1, outN2, outN3);
}

TriangleMesh* create_triangle_mesh_from_managed(ManagedTriangleData* managedArray) {
	if (!managedArray || !managedArray->array)
		throw std::runtime_error("Invalid managed triangle data");
	std::vector<Message> messages;
	TriangleMesh* mesh = g_physics.createTriangleMesh(*managedArray->array, messages);
	// TODO: Handle messages (warnings/errors)
	// Expose them to user?
	return mesh;
}

ConvexMesh* create_convex_mesh_from_managed_vertex_array(ManagedVertexData* managedArray) {
	if (!managedArray || !managedArray->array)
		throw std::runtime_error("Invalid managed vertex data");
	std::vector<Message> messages;
	ConvexMesh* mesh = g_physics.createConvexMesh(*managedArray->array, messages);
	// TODO: Handle messages (warnings/errors)
	// Expose them to user?
	return mesh;
}

ConvexMesh* create_convex_mesh_from_polygon_data(ManagedPolygonData* managedArray) {
	if (!managedArray || !managedArray->array)
		throw std::runtime_error("Invalid managed polygon data");
	std::vector<Message> messages;
	ConvexMesh* mesh = g_physics.createConvexMesh(*managedArray->array, messages);
	// TODO: Handle messages (warnings/errors)
	// Expose them to user?
	return mesh;
}

uint32 polygon_vertex_array_get_vertex_index_in_face(const PolygonVertexArray& array, uint32 faceIndex, uint32 vertexInFace) {
	return array.getVertexIndexInFace(faceIndex, vertexInFace);
}

// Shape conversion functions
CollisionShape* sphere_to_collision_shape(SphereShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

CollisionShape* box_to_collision_shape(BoxShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

CollisionShape* capsule_to_collision_shape(CapsuleShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

CollisionShape* triangle_to_collision_shape(TriangleShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

CollisionShape* convex_mesh_to_collision_shape(ConvexMeshShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

CollisionShape* height_field_to_collision_shape(HeightFieldShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

CollisionShape* concave_mesh_to_collision_shape(ConcaveMeshShape* shape) {
	return static_cast<CollisionShape*>(shape);
}

Body* rigid_body_to_body(RigidBody* rigidBody) {
	return static_cast<Body*>(rigidBody);
}

void body_cleanup_user_data(Body* body) {
	CScriptAny* userData = static_cast<CScriptAny*>(body->getUserData());
	if (userData) {
		userData->Release();
		body->setUserData(nullptr);
	}
}

void body_set_user_data(Body* body, CScriptAny* userData) {
	body_cleanup_user_data(body);
	if (userData) {
		userData->AddRef();
		body->setUserData(userData);
	} else
		body->setUserData(nullptr);
}

CScriptAny* body_get_user_data(Body* body) {
	CScriptAny* userData = static_cast<CScriptAny*>(body->getUserData());
	if (userData) {
		userData->AddRef();  // Caller gets a reference
	}
	return userData;
}

// Must have this, otherwise we leak memory
void world_destroy_rigid_body(PhysicsWorld* world, RigidBody* body) {
	body_cleanup_user_data(body);
	world->destroyRigidBody(body);
}

HeightField* create_height_field_float(int nbGridColumns, int nbGridRows, CScriptArray* heightData, decimal integerHeightScale) {
	if (!heightData) throw std::runtime_error("Height data array cannot be null");
	uint32 expectedSize = nbGridColumns * nbGridRows;
	if (heightData->GetSize() != expectedSize) {
		throw std::runtime_error("Height data array size (" + std::to_string(heightData->GetSize()) + ") must match grid dimensions (" + std::to_string(expectedSize) + ")");
	}
	std::vector<float> heightBuffer(expectedSize);
	for (uint32 i = 0; i < expectedSize; i++)
		heightBuffer[i] = *(float*)heightData->At(i);
	std::vector<Message> messages;
	HeightField* heightField = g_physics.createHeightField(nbGridColumns, nbGridRows, heightBuffer.data(), HeightField::HeightDataType::HEIGHT_FLOAT_TYPE, messages, integerHeightScale);
	// TODO: Handle messages - could expose them to script or log them
	return heightField;
}

HeightField* create_height_field_int(int nbGridColumns, int nbGridRows, CScriptArray* heightData, decimal integerHeightScale) {
	if (!heightData) throw std::runtime_error("Height data array cannot be null");
	uint32 expectedSize = nbGridColumns * nbGridRows;
	if (heightData->GetSize() != expectedSize) {
		throw std::runtime_error("Height data array size (" + std::to_string(heightData->GetSize()) + ") must match grid dimensions (" + std::to_string(expectedSize) + ")");
	}
	std::vector<int> heightBuffer(expectedSize);
	for (uint32 i = 0; i < expectedSize; i++)
		heightBuffer[i] = *(int*)heightData->At(i);
	std::vector<Message> messages;
	HeightField* heightField = g_physics.createHeightField(nbGridColumns, nbGridRows, heightBuffer.data(), HeightField::HeightDataType::HEIGHT_INT_TYPE, messages, integerHeightScale);
	return heightField;
}

HeightField* create_height_field_double(int nbGridColumns, int nbGridRows, CScriptArray* heightData, decimal integerHeightScale) {
	if (!heightData) throw std::runtime_error("Height data array cannot be null");
	uint32 expectedSize = nbGridColumns * nbGridRows;
	if (heightData->GetSize() != expectedSize) {
		throw std::runtime_error("Height data array size (" + std::to_string(heightData->GetSize()) + ") must match grid dimensions (" + std::to_string(expectedSize) + ")");
	}
	std::vector<double> heightBuffer(expectedSize);
	for (uint32 i = 0; i < expectedSize; i++)
		heightBuffer[i] = *(double*)heightData->At(i);
	std::vector<Message> messages;
	HeightField* heightField = g_physics.createHeightField(nbGridColumns, nbGridRows, heightBuffer.data(), HeightField::HeightDataType::HEIGHT_DOUBLE_TYPE, messages, integerHeightScale);
	return heightField;
}

DefaultLogger* create_default_logger() {
	return g_physics.createDefaultLogger();
}

void destroy_default_logger(DefaultLogger* logger) {
	if (logger)
		g_physics.destroyDefaultLogger(logger);
}

Logger* default_logger_to_logger(DefaultLogger* defaultLogger) {
	return static_cast<Logger*>(defaultLogger);
}

// Logger get/set wrappers (static methods)
Logger* get_current_logger() {
	return PhysicsCommon::getLogger();
}

void set_current_logger(Logger* logger) {
	PhysicsCommon::setLogger(logger);
}

// Logger convenience methods
void logger_log_simple(Logger* logger, int level, const std::string& worldName, int category, const std::string& message) {
	if (logger)
		logger->log(static_cast<Logger::Level>(level), worldName, static_cast<Logger::Category>(category), message, "", 0);
}

// Static helper methods wrappers
std::string logger_get_category_name(int category) {
	return Logger::getCategoryName(static_cast<Logger::Category>(category));
}

std::string logger_get_level_name(int level) {
	return Logger::getLevelName(static_cast<Logger::Level>(level));
}

// DefaultLogger destination wrappers
void default_logger_add_file_destination(DefaultLogger* logger, const std::string& filePath, uint32_t logLevelFlag, int format) {
	if (logger)
		logger->addFileDestination(filePath, logLevelFlag, static_cast<DefaultLogger::Format>(format));
}

void default_logger_remove_all_destinations(DefaultLogger* logger) {
	if (logger)
		logger->removeAllDestinations();
}

// Registration templates
template <class T>
void RegisterCollisionShape(asIScriptEngine* engine, const string& type) {
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
	engine->RegisterObjectMethod(type.c_str(), "aabb compute_transformed_aabb(const physics_transform&in transform) const", asMETHOD(T, computeTransformedAABB), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string opImplConv() const", asMETHOD(T, to_string), asCALL_THISCALL);
}

template <class T>
void RegisterPhysicsBody(asIScriptEngine* engine, const string& type) {
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "physics_entity get_entity() const property", asMETHOD(T, getEntity), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_active() const property", asMETHOD(T, isActive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_is_active(bool is_active) property", asMETHOD(T, setIsActive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const physics_transform& get_transform() const property", asMETHOD(T, getTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_transform(const physics_transform&in transform) property", asMETHOD(T, setTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod(
	    type.c_str(),
	    "physics_collider@ add_collider(physics_collision_shape@ shape, const physics_transform&in transform)",
	    asMETHOD(T, addCollider),
	    asCALL_THISCALL);
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
	engine->RegisterObjectMethod(type.c_str(), "void set_user_data(any@ userData)", asFUNCTION(body_set_user_data), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "any@ get_user_data() const", asFUNCTION(body_get_user_data), asCALL_CDECL_OBJFIRST);
}

template <class T>
void RegisterConvexShape(asIScriptEngine* engine, const string& type) {
	RegisterCollisionShape<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "float get_margin() const property", asMETHOD(T, getMargin), asCALL_THISCALL);
}

template <class T>
void RegisterConvexPolyhedronShape(asIScriptEngine* engine, const string& type) {
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

template <class T>
void RegisterConcaveShape(asIScriptEngine* engine, const string& type) {
	RegisterCollisionShape<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "physics_triangle_raycast_side get_raycast_test_type() const property", asMETHOD(ConcaveShape, getRaycastTestType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_raycast_test_type(physics_triangle_raycast_side side) property", asMETHOD(ConcaveShape, setRaycastTestType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "vector get_scale() const property", asMETHOD(ConcaveShape, getScale), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_scale(const vector &in scale) property", asMETHOD(ConcaveShape, setScale), asCALL_THISCALL);
}

void RegisterEnumsAndConstants(asIScriptEngine* engine) {
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
	engine->RegisterEnum("physics_logger_level");
	engine->RegisterEnumValue("physics_logger_level", "LOGGER_LEVEL_ERROR", static_cast<int>(Logger::Level::Error));
	engine->RegisterEnumValue("physics_logger_level", "LOGGER_LEVEL_WARNING", static_cast<int>(Logger::Level::Warning));
	engine->RegisterEnumValue("physics_logger_level", "LOGGER_LEVEL_INFORMATION", static_cast<int>(Logger::Level::Information));
	engine->RegisterEnum("physics_logger_category");
	engine->RegisterEnumValue("physics_logger_category", "LOGGER_CATEGORY_PHYSICS_COMMON", static_cast<int>(Logger::Category::PhysicCommon));
	engine->RegisterEnumValue("physics_logger_category", "LOGGER_CATEGORY_WORLD", static_cast<int>(Logger::Category::World));
	engine->RegisterEnumValue("physics_logger_category", "LOGGER_CATEGORY_BODY", static_cast<int>(Logger::Category::Body));
	engine->RegisterEnumValue("physics_logger_category", "LOGGER_CATEGORY_JOINT", static_cast<int>(Logger::Category::Joint));
	engine->RegisterEnumValue("physics_logger_category", "LOGGER_CATEGORY_COLLIDER", static_cast<int>(Logger::Category::Collider));
	engine->RegisterEnum("physics_logger_format");
	engine->RegisterEnumValue("physics_logger_format", "LOGGER_FORMAT_TEXT", static_cast<int>(DefaultLogger::Format::Text));
	engine->RegisterEnumValue("physics_logger_format", "LOGGER_FORMAT_HTML", static_cast<int>(DefaultLogger::Format::HTML));
}

void RegisterMathTypes(asIScriptEngine* engine) {
	engine->RegisterObjectType("vector", sizeof(Vector3), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Vector3>() | asOBJ_APP_CLASS_ALLFLOATS);
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
	engine->RegisterObjectType("physics_transform", sizeof(Transform), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Transform>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<Transform>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_CONSTRUCT, "void f(const vector&in position, const matrix3x3&in orientation)", asFUNCTION((rp_construct<Transform, const Vector3&, const Matrix3x3&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_CONSTRUCT, "void f(const vector&in position, const quaternion&in orientation)", asFUNCTION((rp_construct<Transform, const Vector3&, const Quaternion&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_transform", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Transform>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "const vector& get_position() const property", asMETHOD(Transform, getPosition), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "const quaternion& get_orientation() const property", asMETHOD(Transform, getOrientation), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "void set_position(const vector&in position) property", asMETHOD(Transform, setPosition), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "void set_orientation(const quaternion&in orientation) property", asMETHOD(Transform, setOrientation), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "void set_to_identity()", asMETHOD(Transform, setToIdentity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "physics_transform get_inverse() const property", asMETHOD(Transform, getInverse), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "bool get_is_valid() const property", asMETHOD(Transform, isValid), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "void set_from_opengl_matrix(float[]@ matrix)", asFUNCTION(transform_set_from_opengl_matrix), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "float[]@ get_opengl_matrix() const", asFUNCTION(transform_get_opengl_matrix), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_transform", "bool opEquals(const physics_transform&in) const", asMETHOD(Transform, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "physics_transform opMul(const physics_transform&in) const", asMETHODPR(Transform, operator*, (const Transform&) const, Transform), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "vector opMul(const vector&in) const", asMETHODPR(Transform, operator*, (const Vector3&) const, Vector3), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_transform", "string opImplConv()", asMETHOD(Transform, to_string), asCALL_THISCALL);
	engine->RegisterGlobalFunction("physics_transform get_IDENTITY_TRANSFORM() property", asFUNCTION(Transform::identity), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_transform transforms_interpolate()", asFUNCTION(Transform::interpolateTransforms), asCALL_CDECL);
}

void RegisterCorePhysicsTypes(asIScriptEngine* engine) {
	// Forward declare types to be registered later
	engine->RegisterObjectType("physics_body", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_collider", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_entity", sizeof(Entity), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Entity>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("physics_entity", asBEHAVE_CONSTRUCT, "void f(uint index, uint generation)", asFUNCTION((rp_construct<Entity, uint32, uint32>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_entity", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Entity>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_entity", "uint id", asOFFSET(Entity, id));
	engine->RegisterObjectMethod("physics_entity", "uint get_index() const property", asMETHOD(Entity, getIndex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_entity", "uint get_generation() const property", asMETHOD(Entity, getGeneration), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_entity", "bool opEquals(const physics_entity&in entity) const", asMETHOD(Entity, operator==), asCALL_THISCALL);
	engine->RegisterObjectType("ray", sizeof(Ray), asOBJ_VALUE | asGetTypeTraits<Ray>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("ray", asBEHAVE_CONSTRUCT, "void f(const vector&in p1, const vector&in p2, float max_frac = 1.0f)", asFUNCTION((rp_construct<Ray, const Vector3&, const Vector3&, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ray", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Ray>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("ray", "vector point1", asOFFSET(Ray, point1));
	engine->RegisterObjectProperty("ray", "vector point2", asOFFSET(Ray, point2));
	engine->RegisterObjectProperty("ray", "float max_fraction", asOFFSET(Ray, maxFraction));
	engine->RegisterObjectType("aabb", sizeof(AABB), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<AABB>() | asOBJ_APP_CLASS_ALLFLOATS);
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
	engine->RegisterObjectType("raycast_info", sizeof(RaycastInfo), asOBJ_VALUE | asGetTypeTraits<RaycastInfo>());
	engine->RegisterObjectBehaviour("raycast_info", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION((rp_construct<RaycastInfo>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("raycast_info", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<RaycastInfo>), asCALL_CDECL_OBJFIRST);
	engine->RegisterFuncdef("float physics_raycast_callback(const raycast_info&in info)");
	engine->RegisterObjectProperty("raycast_info", "vector world_point", asOFFSET(RaycastInfo, worldPoint));
	engine->RegisterObjectProperty("raycast_info", "vector world_normal", asOFFSET(RaycastInfo, worldNormal));
	engine->RegisterObjectProperty("raycast_info", "float hit_fraction", asOFFSET(RaycastInfo, hitFraction));
	engine->RegisterObjectProperty("raycast_info", "int triangle_index", asOFFSET(RaycastInfo, triangleIndex));
	engine->RegisterObjectProperty("raycast_info", "physics_body@ body", asOFFSET(RaycastInfo, body));
	engine->RegisterObjectProperty("raycast_info", "physics_collider@ collider", asOFFSET(RaycastInfo, collider));
	engine->RegisterEnum("physics_message_type");
	engine->RegisterEnumValue("physics_message_type", "PHYSICS_MESSAGE_ERROR", int(Message::Type::Error));
	engine->RegisterEnumValue("physics_message_type", "PHYSICS_MESSAGE_WARNING", int(Message::Type::Warning));
	engine->RegisterEnumValue("physics_message_type", "PHYSICS_MESSAGE_INFORMATION", int(Message::Type::Information));
	engine->RegisterObjectType("physics_message", sizeof(Message), asOBJ_VALUE | asGetTypeTraits<Message>());
	engine->RegisterObjectBehaviour("physics_message", asBEHAVE_CONSTRUCT, "void f(string text, physics_message_type type = PHYSICS_MESSAGE_ERROR)", asFUNCTION((rp_construct<Message, std::string, Message::Type>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_message", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Message>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_message", "string text", asOFFSET(Message, text));
	engine->RegisterObjectProperty("physics_message", "physics_message_type type", asOFFSET(Message, type));
}

void RegisterPhysicsEntities(asIScriptEngine* engine) {
	// Forward declare types that will be registered later
	engine->RegisterObjectType("physics_body", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_rigid_body", 0, asOBJ_REF);
	engine->RegisterObjectType("physics_collision_shape", 0, asOBJ_REF);
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
	engine->RegisterObjectType("physics_collider", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_collider", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_collider", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_collider", "physics_entity get_entity() const property", asMETHOD(Collider, getEntity), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "physics_collision_shape@ get_collision_shape() property", asMETHODPR(Collider, getCollisionShape, (), CollisionShape*), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const physics_collision_shape@ get_collision_shape() const property", asMETHODPR(Collider, getCollisionShape, () const, const CollisionShape*), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "physics_body@ get_body() const property", asMETHOD(Collider, getBody), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const physics_transform& get_local_to_body_transform() const property", asMETHOD(Collider, getLocalToBodyTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "void set_local_to_body_transform(const physics_transform&in transform) property", asMETHOD(Collider, setLocalToBodyTransform), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_collider", "const physics_transform get_local_to_world_transform() const", asMETHOD(Collider, getLocalToWorldTransform), asCALL_THISCALL);
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
}

void RegisterPhysicsBodies(asIScriptEngine* engine) {
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
}

void RegisterCollisionShapes(asIScriptEngine* engine) {
	RegisterCollisionShape<CollisionShape>(engine, "physics_collision_shape");
	// Forward declare types to be registered later
	engine->RegisterObjectType("physics_height_field", 0, asOBJ_REF);
	RegisterConvexShape<SphereShape>(engine, "physics_sphere_shape");
	engine->RegisterObjectMethod("physics_sphere_shape", "float get_radius() const property", asMETHOD(SphereShape, getRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_sphere_shape", "void set_radius(float radius) property", asMETHOD(SphereShape, setRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_sphere_shape", "string opImplConv()", asMETHOD(SphereShape, to_string), asCALL_THISCALL);
	RegisterConvexPolyhedronShape<BoxShape>(engine, "physics_box_shape");
	engine->RegisterObjectMethod("physics_box_shape", "vector& get_half_extents() const property", asMETHOD(BoxShape, getHalfExtents), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_box_shape", "void set_half_extents(const vector&in half_extents) property", asMETHOD(BoxShape, setHalfExtents), asCALL_THISCALL);
	RegisterConvexShape<CapsuleShape>(engine, "physics_capsule_shape");
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_radius() const property", asMETHOD(CapsuleShape, getRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "void set_radius(float radius) property", asMETHOD(CapsuleShape, setRadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "float get_height() const property", asMETHOD(CapsuleShape, getHeight), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "void set_height(float height) property", asMETHOD(CapsuleShape, setHeight), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_capsule_shape", "string opImplConv()", asMETHOD(CapsuleShape, to_string), asCALL_THISCALL);
	RegisterConvexPolyhedronShape<TriangleShape>(engine, "physics_triangle_shape");
	engine->RegisterObjectMethod("physics_triangle_shape", "physics_triangle_raycast_side get_raycast_test_type() const property", asMETHOD(TriangleShape, getRaycastTestType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_shape", "void set_raycast_test_type(physics_triangle_raycast_side test_type) property", asMETHOD(TriangleShape, setRaycastTestType), asCALL_THISCALL);
	engine->RegisterGlobalFunction("void physics_triangle_shape_compute_smooth_triangle_mesh_contact(const physics_collision_shape &in shape1, const physics_collision_shape &in shape2, vector & local_contact_point_shape1, vector & local_contact_point_shape2, const physics_transform &in shape1_to_world, const physics_transform &in shape2_to_world, float penitration_depth, vector & out_smooth_vertex_normal)", asFUNCTION(TriangleShape::computeSmoothTriangleMeshContact), asCALL_CDECL);
	RegisterConvexPolyhedronShape<ConvexMeshShape>(engine, "physics_convex_mesh_shape");
	engine->RegisterObjectMethod("physics_convex_mesh_shape", "vector& get_scale() const property", asMETHOD(ConvexMeshShape, getScale), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh_shape", "void set_scale(vector& scale) const property", asMETHOD(ConvexMeshShape, setScale), asCALL_THISCALL);
	RegisterConcaveShape<HeightFieldShape>(engine, "physics_height_field_shape");
	engine->RegisterObjectMethod("physics_height_field_shape", "physics_height_field@ get_height_field() const property", asMETHOD(HeightFieldShape, getHeightField), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_height_field_shape", "vector get_vertex_at(uint x, uint y) const", asMETHOD(HeightFieldShape, getVertexAt), asCALL_THISCALL);
}

void RegisterHalfEdgeStructure(asIScriptEngine* engine) {
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
	engine->RegisterObjectType("physics_half_edge_structure", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_half_edge_structure", "void compute_half_edges()", asMETHOD(HalfEdgeStructure, computeHalfEdges), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint add_vertex(uint vertex_point_index)", asMETHOD(HalfEdgeStructure, addVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint get_nb_faces() const property", asMETHOD(HalfEdgeStructure, getNbFaces), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint get_nb_half_edges() const property", asMETHOD(HalfEdgeStructure, getNbHalfEdges), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "uint get_nb_vertices() const property", asMETHOD(HalfEdgeStructure, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_half_edge_structure", "const physics_half_edge_structure_face& get_face(uint index) const property", asMETHOD(HalfEdgeStructure, getFace), asCALL_THISCALL);
}

void RegisterVertexArrays(asIScriptEngine* engine) {
	engine->RegisterEnum("physics_triangle_vertex_data_type");
	engine->RegisterEnumValue("physics_triangle_vertex_data_type", "TRIANGLE_VERTEX_FLOAT_TYPE", int(TriangleVertexArray::VertexDataType::VERTEX_FLOAT_TYPE));
	engine->RegisterEnumValue("physics_triangle_vertex_data_type", "TRIANGLE_VERTEX_DOUBLE_TYPE", int(TriangleVertexArray::VertexDataType::VERTEX_DOUBLE_TYPE));
	engine->RegisterEnum("physics_triangle_normal_data_type");
	engine->RegisterEnumValue("physics_triangle_normal_data_type", "TRIANGLE_NORMAL_FLOAT_TYPE", int(TriangleVertexArray::NormalDataType::NORMAL_FLOAT_TYPE));
	engine->RegisterEnumValue("physics_triangle_normal_data_type", "TRIANGLE_NORMAL_DOUBLE_TYPE", int(TriangleVertexArray::NormalDataType::NORMAL_DOUBLE_TYPE));
	engine->RegisterEnum("physics_triangle_index_data_type");
	engine->RegisterEnumValue("physics_triangle_index_data_type", "TRIANGLE_INDEX_INTEGER_TYPE", int(TriangleVertexArray::IndexDataType::INDEX_INTEGER_TYPE));
	engine->RegisterEnumValue("physics_triangle_index_data_type", "TRIANGLE_INDEX_SHORT_TYPE", int(TriangleVertexArray::IndexDataType::INDEX_SHORT_TYPE));
	engine->RegisterEnum("physics_vertex_data_type");
	engine->RegisterEnumValue("physics_vertex_data_type", "VERTEX_FLOAT_TYPE", int(VertexArray::DataType::VERTEX_FLOAT_TYPE));
	engine->RegisterEnumValue("physics_vertex_data_type", "VERTEX_DOUBLE_TYPE", int(VertexArray::DataType::VERTEX_DOUBLE_TYPE));
	engine->RegisterObjectType("physics_triangle_data", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_triangle_data", asBEHAVE_FACTORY, "physics_triangle_data@ f(float[]@ vertices, uint[]@ indices)", asFUNCTION(create_triangle_data), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_triangle_data", asBEHAVE_FACTORY, "physics_triangle_data@ f(float[]@ vertices, float[]@ normals, uint[]@ indices)", asFUNCTION(create_triangle_data_with_normals), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_triangle_data", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_triangle_data", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType("physics_vertex_data", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_vertex_data", asBEHAVE_FACTORY, "physics_vertex_data@ f(float[]@ vertices)", asFUNCTION(create_vertex_data), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_vertex_data", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_vertex_data", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	// Register the actual TriangleVertexArray (read-only, created by managed wrapper)
	engine->RegisterObjectType("physics_triangle_vertex_array", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "physics_triangle_vertex_data_type get_vertex_data_type() const property", asMETHOD(TriangleVertexArray, getVertexDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "physics_triangle_normal_data_type get_vertex_normal_data_type() const property", asMETHOD(TriangleVertexArray, getVertexNormalDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "bool get_has_normals() const property", asMETHOD(TriangleVertexArray, getHasNormals), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "physics_triangle_index_data_type get_index_data_type() const property", asMETHOD(TriangleVertexArray, getIndexDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "uint get_nb_vertices() const property", asMETHOD(TriangleVertexArray, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "uint get_nb_triangles() const property", asMETHOD(TriangleVertexArray, getNbTriangles), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "uint get_vertices_stride() const property", asMETHOD(TriangleVertexArray, getVerticesStride), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "uint get_vertices_normals_stride() const property", asMETHOD(TriangleVertexArray, getVerticesNormalsStride), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "uint get_indices_stride() const property", asMETHOD(TriangleVertexArray, getIndicesStride), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "void get_triangle_vertices_indices(uint triangle_index, uint&out v1_index, uint&out v2_index, uint&out v3_index) const", asFUNCTION(triangle_vertex_array_get_triangle_vertices_indices), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "vector get_vertex(uint vertex_index) const", asMETHOD(TriangleVertexArray, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_vertex_array", "vector get_vertex_normal(uint vertex_index) const", asMETHOD(TriangleVertexArray, getVertexNormal), asCALL_THISCALL);
	// Register the actual VertexArray (read-only, created by managed wrapper)
	engine->RegisterObjectType("physics_vertex_array", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_vertex_array", "physics_vertex_data_type get_data_type() const property", asMETHOD(VertexArray, getDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_vertex_array", "uint get_nb_vertices() const property", asMETHOD(VertexArray, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_vertex_array", "uint get_stride() const property", asMETHOD(VertexArray, getStride), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_vertex_array", "vector get_vertex(uint index) const", asMETHOD(VertexArray, getVertex), asCALL_THISCALL);
	engine->RegisterEnum("physics_polygon_vertex_data_type");
	engine->RegisterEnumValue("physics_polygon_vertex_data_type", "POLYGON_VERTEX_FLOAT_TYPE", int(PolygonVertexArray::VertexDataType::VERTEX_FLOAT_TYPE));
	engine->RegisterEnumValue("physics_polygon_vertex_data_type", "POLYGON_VERTEX_DOUBLE_TYPE", int(PolygonVertexArray::VertexDataType::VERTEX_DOUBLE_TYPE));
	engine->RegisterEnum("physics_polygon_index_data_type");
	engine->RegisterEnumValue("physics_polygon_index_data_type", "POLYGON_INDEX_INTEGER_TYPE", int(PolygonVertexArray::IndexDataType::INDEX_INTEGER_TYPE));
	engine->RegisterEnumValue("physics_polygon_index_data_type", "POLYGON_INDEX_SHORT_TYPE", int(PolygonVertexArray::IndexDataType::INDEX_SHORT_TYPE));
	engine->RegisterObjectType("physics_polygon_face", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_polygon_face", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_polygon_face", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("physics_polygon_face", "uint nb_vertices", asOFFSET(PolygonVertexArray::PolygonFace, nbVertices));
	engine->RegisterObjectProperty("physics_polygon_face", "uint index_base", asOFFSET(PolygonVertexArray::PolygonFace, indexBase));
	// Register managed polygon data wrapper
	engine->RegisterObjectType("physics_polygon_data", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_polygon_data", asBEHAVE_FACTORY, "physics_polygon_data@ f(float[]@ vertices, array<array<uint>>@ faces)", asFUNCTION(create_polygon_data), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_polygon_data", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_polygon_data", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	// Register the actual PolygonVertexArray (read-only, created by managed wrapper)
	engine->RegisterObjectType("physics_polygon_vertex_array", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "physics_polygon_vertex_data_type get_vertex_data_type() const property", asMETHOD(PolygonVertexArray, getVertexDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "physics_polygon_index_data_type get_index_data_type() const property", asMETHOD(PolygonVertexArray, getIndexDataType), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "uint get_nb_vertices() const property", asMETHOD(PolygonVertexArray, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "uint get_nb_faces() const property", asMETHOD(PolygonVertexArray, getNbFaces), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "uint get_vertices_stride() const property", asMETHOD(PolygonVertexArray, getVerticesStride), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "uint get_indices_stride() const property", asMETHOD(PolygonVertexArray, getIndicesStride), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "uint get_vertex_index_in_face(uint face_index, uint vertex_in_face) const", asFUNCTION(polygon_vertex_array_get_vertex_index_in_face), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "vector get_vertex(uint vertex_index) const", asMETHOD(PolygonVertexArray, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_polygon_vertex_array", "physics_polygon_face@ get_polygon_face(uint face_index) const", asMETHOD(PolygonVertexArray, getPolygonFace), asCALL_THISCALL);
}

void RegisterTriangleMeshAndConcaveShape(asIScriptEngine* engine) {
	engine->RegisterObjectType("physics_triangle_mesh", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_triangle_mesh", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_triangle_mesh", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_triangle_mesh", "uint get_nb_vertices() const property", asMETHOD(TriangleMesh, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_mesh", "uint get_nb_triangles() const property", asMETHOD(TriangleMesh, getNbTriangles), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_mesh", "const aabb& get_bounds() const property", asMETHOD(TriangleMesh, getBounds), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_mesh", "void get_triangle_vertices_indices(uint triangle_index, uint&out v1_index, uint&out v2_index, uint&out v3_index) const", asFUNCTION(triangle_mesh_get_triangle_vertices_indices), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_triangle_mesh", "void get_triangle_vertices(uint triangle_index, vector&out v1, vector&out v2, vector&out v3) const", asFUNCTION(triangle_mesh_get_triangle_vertices), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_triangle_mesh", "void get_triangle_vertices_normals(uint triangle_index, vector&out n1, vector&out n2, vector&out n3) const", asFUNCTION(triangle_mesh_get_triangle_vertices_normals), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_triangle_mesh", "const vector& get_vertex(uint vertex_index) const", asMETHOD(TriangleMesh, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_triangle_mesh", "const vector& get_vertex_normal(uint vertex_index) const", asMETHOD(TriangleMesh, getVertexNormal), asCALL_THISCALL);
	RegisterConcaveShape<ConcaveMeshShape>(engine, "physics_concave_mesh_shape");
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "uint get_nb_vertices() const property", asMETHOD(ConcaveMeshShape, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "uint get_nb_triangles() const property", asMETHOD(ConcaveMeshShape, getNbTriangles), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "void get_triangle_vertices_indices(uint triangle_index, uint&out v1_index, uint&out v2_index, uint&out v3_index) const", asFUNCTION(concave_mesh_shape_get_triangle_vertices_indices), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "void get_triangle_vertices(uint triangle_index, vector&out v1, vector&out v2, vector&out v3) const", asFUNCTION(concave_mesh_shape_get_triangle_vertices), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "void get_triangle_vertices_normals(uint triangle_index, vector&out n1, vector&out n2, vector&out n3) const", asFUNCTION(concave_mesh_shape_get_triangle_vertices_normals), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "vector get_vertex(uint vertex_index) const", asMETHOD(ConcaveMeshShape, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "const vector& get_vertex_normal(uint vertex_index) const", asMETHOD(ConcaveMeshShape, getVertexNormal), asCALL_THISCALL);
}

void RegisterPhysicsWorldAndCallbacks(asIScriptEngine* engine) {
	engine->RegisterObjectType("physics_contact_point", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_contact_point", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_contact_point", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_contact_point", "const vector& get_world_normal() const property", asMETHOD(CollisionCallback::ContactPoint, getWorldNormal), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_point", "const vector& get_local_point_on_collider1() const property", asMETHOD(CollisionCallback::ContactPoint, getLocalPointOnCollider1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_point", "const vector& get_local_point_on_collider2() const property", asMETHOD(CollisionCallback::ContactPoint, getLocalPointOnCollider2), asCALL_THISCALL);
	engine->RegisterObjectType("physics_contact_pair", sizeof(CollisionCallback::ContactPair), asOBJ_VALUE | asGetTypeTraits<CollisionCallback::ContactPair>());
	engine->RegisterObjectBehaviour("physics_contact_pair", asBEHAVE_CONSTRUCT, "void f(const physics_contact_pair&in pair)", asFUNCTION((rp_construct<CollisionCallback::ContactPair, const CollisionCallback::ContactPair&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_contact_pair", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<CollisionCallback::ContactPair>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_contact_pair", "uint get_nb_contact_points() const property", asMETHOD(CollisionCallback::ContactPair, getNbContactPoints), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_contact_point@ get_contact_point(uint index) const", asMETHOD(CollisionCallback::ContactPair, getContactPoint), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_body@ get_body1() const property", asMETHOD(CollisionCallback::ContactPair, getBody1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_body@ get_body2() const property", asMETHOD(CollisionCallback::ContactPair, getBody2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_collider@ get_collider1() const property", asMETHOD(CollisionCallback::ContactPair, getCollider1), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_collider@ get_collider2() const property", asMETHOD(CollisionCallback::ContactPair, getCollider2), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_contact_pair", "physics_contact_event_type get_event_type() const property", asMETHOD(CollisionCallback::ContactPair, getEventType), asCALL_THISCALL);
	engine->RegisterObjectType("physics_collision_callback_data", 0, asOBJ_REF | asOBJ_NOHANDLE);
	engine->RegisterFuncdef("void physics_collision_callback(const physics_collision_callback_data& data)");
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
	engine->RegisterFuncdef("void physics_overlap_callback(const physics_overlap_callback_data& data)");
	engine->RegisterObjectMethod("physics_overlap_callback_data", "uint get_nb_overlap_pairs() const property", asMETHOD(OverlapCallback::CallbackData, getNbOverlappingPairs), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_overlap_callback_data", "physics_overlap_pair get_overlapping_pair(uint index) const", asMETHOD(OverlapCallback::CallbackData, getOverlappingPair), asCALL_THISCALL);
	engine->RegisterObjectType("physics_world_settings", sizeof(PhysicsWorld::WorldSettings), asOBJ_VALUE | asGetTypeTraits<PhysicsWorld::WorldSettings>());
	engine->RegisterObjectBehaviour("physics_world_settings", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(rp_construct<PhysicsWorld::WorldSettings>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_world_settings", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<PhysicsWorld::WorldSettings>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_world_settings", asBEHAVE_CONSTRUCT, "void f(const physics_world_settings &in)", asFUNCTION((rp_copy_construct<PhysicsWorld::WorldSettings>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world_settings", "physics_world_settings &opAssign(const physics_world_settings &in)", asMETHODPR(PhysicsWorld::WorldSettings, operator=, (const PhysicsWorld::WorldSettings&), PhysicsWorld::WorldSettings&), asCALL_THISCALL);
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
	engine->RegisterObjectType("physics_world", 0, asOBJ_REF);
	engine->RegisterGlobalFunction("void physics_world_destroy(physics_world& world)", asFUNCTION(world_destroy), asCALL_CDECL);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_FACTORY, "physics_world@ w(const physics_world_settings&in world_settings)", asMETHOD(PhysicsCommon, createPhysicsWorld), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_world", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_world", "bool test_overlap(physics_body@ body1, physics_body@ body2)", asMETHODPR(PhysicsWorld, testOverlap, (Body*, Body*), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void raycast(const ray&in ray, physics_raycast_callback@ callback, uint16 category_mask = 0xffff)", asFUNCTION(world_raycast), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectMethod("physics_world", "physics_rigid_body@ create_rigid_body(const physics_transform&in transform)", asMETHOD(PhysicsWorld, createRigidBody), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_world", "void destroy_rigid_body(physics_rigid_body& body)", asFUNCTION(world_destroy_rigid_body), asCALL_CDECL_OBJFIRST);
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
}

void RegisterJointTypes(asIScriptEngine* engine) {
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
}

void RegisterHeightFieldAndMeshTypes(asIScriptEngine* engine) {
	engine->RegisterEnum("physics_height_data_type");
	engine->RegisterEnumValue("physics_height_data_type", "PHYSICS_HEIGHT_FLOAT_TYPE", int(HeightField::HeightDataType::HEIGHT_FLOAT_TYPE));
	engine->RegisterEnumValue("physics_height_data_type", "PHYSICS_HEIGHT_DOUBLE_TYPE", int(HeightField::HeightDataType::HEIGHT_DOUBLE_TYPE));
	engine->RegisterEnumValue("physics_height_data_type", "PHYSICS_HEIGHT_INT_TYPE", int(HeightField::HeightDataType::HEIGHT_INT_TYPE));
	engine->RegisterObjectType("physics_height_field", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_height_field", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_height_field", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectType("physics_convex_mesh", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("physics_convex_mesh", asBEHAVE_ADDREF, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("physics_convex_mesh", asBEHAVE_RELEASE, "void f()", asFUNCTION(no_refcount), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_convex_mesh", "uint get_nb_vertices() const property", asMETHOD(ConvexMesh, getNbVertices), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "const vector& get_vertex(uint index) const", asMETHOD(ConvexMesh, getVertex), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "uint get_nb_faces() const property", asMETHOD(ConvexMesh, getNbFaces), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "const vector& get_face_normal(uint index) const", asMETHOD(ConvexMesh, getFaceNormal), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "const physics_half_edge_structure& get_half_edge_structure() const property", asMETHOD(ConvexMesh, getHalfEdgeStructure), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "const vector& get_centroid() const property", asMETHOD(ConvexMesh, getCentroid), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "const aabb& get_bounds() const property", asMETHOD(ConvexMesh, getBounds), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "float get_volume() const property", asMETHOD(ConvexMesh, getVolume), asCALL_THISCALL);
	engine->RegisterObjectMethod("physics_convex_mesh", "vector get_local_inertia_tensor(float mass, vector scale) const", asMETHOD(ConvexMesh, getLocalInertiaTensor), asCALL_THISCALL);
}

void RegisterPhysicsCommonFactories(asIScriptEngine* engine) {
	// Collision Shape Factories
	engine->RegisterObjectBehaviour("physics_concave_mesh_shape", asBEHAVE_FACTORY, "physics_concave_mesh_shape@ f(physics_triangle_mesh@ triangle_mesh, const vector&in scaling = vector(1,1,1))", asMETHOD(PhysicsCommon, createConcaveMeshShape), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_sphere_shape", asBEHAVE_FACTORY, "physics_sphere_shape@ f(float radius)", asMETHOD(PhysicsCommon, createSphereShape), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_box_shape", asBEHAVE_FACTORY, "physics_box_shape@ f(const vector&in half_extents)", asMETHOD(PhysicsCommon, createBoxShape), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_capsule_shape", asBEHAVE_FACTORY, "physics_capsule_shape@ f(float radius, float height)", asMETHOD(PhysicsCommon, createCapsuleShape), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_convex_mesh_shape", asBEHAVE_FACTORY, "physics_convex_mesh_shape@ f(physics_convex_mesh@ convex_mesh, const vector&in scaling = vector(1,1,1))", asMETHOD(PhysicsCommon, createConvexMeshShape), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterObjectBehaviour("physics_height_field_shape", asBEHAVE_FACTORY, "physics_height_field_shape@ f(physics_height_field@ height_field, const vector&in scaling = vector(1,1,1))", asMETHOD(PhysicsCommon, createHeightFieldShape), asCALL_THISCALL_ASGLOBAL, &g_physics);
	engine->RegisterGlobalFunction("physics_triangle_mesh@ physics_triangle_mesh_create(physics_triangle_data@ triangle_data)", asFUNCTION(create_triangle_mesh_from_managed), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_convex_mesh@ physics_convex_mesh_create(physics_vertex_data@ vertex_data)", asFUNCTION(create_convex_mesh_from_managed_vertex_array), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_convex_mesh@ physics_convex_mesh_create_from_polygon(physics_polygon_data@ polygon_data)", asFUNCTION(create_convex_mesh_from_polygon_data), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_height_field@ physics_height_field_create(int nb_columns, int nb_rows, float[]@ height_data, float integer_height_scale = 1.0f)", asFUNCTION(create_height_field_float), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_height_field@ physics_height_field_create(int nb_columns, int nb_rows, int[]@ height_data, float integer_height_scale = 1.0f)", asFUNCTION(create_height_field_int), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_height_field@ physics_height_field_create(int nb_columns, int nb_rows, double[]@ height_data, float integer_height_scale = 1.0f)", asFUNCTION(create_height_field_double), asCALL_CDECL);
	// Shape destruction functions
	engine->RegisterGlobalFunction("void physics_sphere_shape_destroy(physics_sphere_shape@ shape)", asFUNCTION(sphere_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_box_shape_destroy(physics_box_shape@ shape)", asFUNCTION(box_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_capsule_shape_destroy(physics_capsule_shape@ shape)", asFUNCTION(capsule_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_convex_mesh_shape_destroy(physics_convex_mesh_shape@ shape)", asFUNCTION(convex_mesh_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_height_field_shape_destroy(physics_height_field_shape@ shape)", asFUNCTION(height_field_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_triangle_mesh_destroy(physics_triangle_mesh@ mesh)", asFUNCTION(triangle_mesh_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_concave_mesh_shape_destroy(physics_concave_mesh_shape@ shape)", asFUNCTION(concave_mesh_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_convex_mesh_destroy(physics_convex_mesh@ mesh)", asFUNCTION(convex_mesh_destroy), asCALL_CDECL);
	// Generic global destroy
	engine->RegisterGlobalFunction("void physics_shape_destroy(physics_collision_shape@ shape)", asFUNCTION(physics_shape_destroy), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_height_field_destroy(physics_height_field@ height_field)", asFUNCTION(height_field_destroy), asCALL_CDECL);
}

void RegisterShapeConversions(asIScriptEngine* engine) {
	engine->RegisterObjectMethod("physics_sphere_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(sphere_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_sphere_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(sphere_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_box_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(box_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_box_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(box_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_capsule_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(capsule_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_capsule_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(capsule_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_triangle_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(triangle_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_triangle_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(triangle_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_convex_mesh_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(convex_mesh_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_convex_mesh_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(convex_mesh_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_height_field_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(height_field_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_height_field_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(height_field_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "physics_collision_shape@ opImplCast()", asFUNCTION(concave_mesh_to_collision_shape), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_concave_mesh_shape", "const physics_collision_shape@ opImplCast() const", asFUNCTION(concave_mesh_to_collision_shape), asCALL_CDECL_OBJLAST);
}

void RegisterBodyConversions(asIScriptEngine* engine) {
	engine->RegisterObjectMethod("physics_rigid_body", "physics_body@ opImplCast()", asFUNCTION(rigid_body_to_body), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_rigid_body", "const physics_body@ opImplCast() const", asFUNCTION(rigid_body_to_body), asCALL_CDECL_OBJLAST);
}

void RegisterLoggerClasses(asIScriptEngine* engine) {
	engine->RegisterObjectType("physics_logger", 0, asOBJ_REF | asOBJ_NOCOUNT);
	engine->RegisterObjectMethod("physics_logger", "void log(physics_logger_level level, const string&in worldName, physics_logger_category category, const string&in message)", asFUNCTION(logger_log_simple), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType("physics_default_logger", 0, asOBJ_REF | asOBJ_NOCOUNT);
	engine->RegisterObjectMethod("physics_default_logger", "void add_file_destination(const string&in filePath, uint logLevelFlag, physics_logger_format format)", asFUNCTION(default_logger_add_file_destination), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("physics_default_logger", "void remove_all_destinations()", asFUNCTION(default_logger_remove_all_destinations), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("physics_default_logger@ physics_default_logger_create()", asFUNCTION(create_default_logger), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_default_logger_destroy(physics_default_logger@ logger)", asFUNCTION(destroy_default_logger), asCALL_CDECL);
	engine->RegisterGlobalFunction("physics_logger@ physics_logger_get_current()", asFUNCTION(get_current_logger), asCALL_CDECL);
	engine->RegisterGlobalFunction("void physics_logger_set_current(physics_logger@ logger)", asFUNCTION(set_current_logger), asCALL_CDECL);
	engine->RegisterGlobalFunction("string physics_logger_get_category_name(physics_logger_category category)", asFUNCTION(logger_get_category_name), asCALL_CDECL);
	engine->RegisterGlobalFunction("string physics_logger_get_level_name(physics_logger_level level)", asFUNCTION(logger_get_level_name), asCALL_CDECL);
	engine->RegisterObjectMethod("physics_default_logger", "physics_logger@ opImplCast()", asFUNCTION(default_logger_to_logger), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("physics_default_logger", "const physics_logger@ opImplCast() const", asFUNCTION(default_logger_to_logger), asCALL_CDECL_OBJLAST);
}

void RegisterReactphysics(asIScriptEngine* engine) {
	RegisterMathTypes(engine);
	RegisterEnumsAndConstants(engine);
	RegisterLoggerClasses(engine);
	RegisterCorePhysicsTypes(engine);
	RegisterHalfEdgeStructure(engine);
	RegisterPhysicsEntities(engine);
	RegisterCollisionShapes(engine);
	RegisterPhysicsBodies(engine);
	RegisterJointTypes(engine);
	RegisterHeightFieldAndMeshTypes(engine);
	RegisterVertexArrays(engine);
	RegisterTriangleMeshAndConcaveShape(engine);
	RegisterPhysicsWorldAndCallbacks(engine);
	RegisterPhysicsCommonFactories(engine);
	RegisterShapeConversions(engine);
	RegisterBodyConversions(engine);
}
