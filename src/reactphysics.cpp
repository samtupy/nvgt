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
#include <scriptarray.h>
#include <reactphysics3d/reactphysics3d.h>
#include "nvgt_angelscript.h"
#include "reactphysics.h"

using namespace std;
using namespace reactphysics3d;

PhysicsCommon g_physics;

// Angelscript factories.
template <class T, typename... A> void rp_construct(void* mem, A... args) { new (mem) T(args...); }
template <class T> void rp_copy_construct(void* mem, const T& obj) { new(mem) T(obj); }
template <class T> void rp_destruct(T* obj) { obj->~T(); }

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

// registration templates
template <class T> void RegisterCollisionShape() {
	
}

void RegisterReactphysics(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction("int clamp(int value, int min, int max)", asFUNCTIONPR(clamp, (int, int, int), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("float clamp(float value, float min, float max)", asFUNCTIONPR(clamp, (decimal, decimal, decimal), decimal), asCALL_CDECL);
	engine->RegisterEnum("physics_shape_type");
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_SPHERE", int(CollisionShapeType::SPHERE));
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_CAPSULE", int(CollisionShapeType::CAPSULE));
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_CONVEX_POLYHEDRON", int(CollisionShapeType::CONVEX_POLYHEDRON));
	engine->RegisterEnumValue("physics_shape_type", "SHAPE_TYPE_CONCAVE", int(CollisionShapeType::CONCAVE_SHAPE));
	engine->RegisterGlobalProperty("const float EPSILON", (void*)&MACHINE_EPSILON);
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

	engine->RegisterObjectType("ray", sizeof(Ray), asOBJ_VALUE | asGetTypeTraits<Ray>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectBehaviour("ray", asBEHAVE_CONSTRUCT, "void f(const vector&in p1, const vector&in p2, float max_frac = 1.0f)", asFUNCTION((rp_construct<Ray, const Vector3&, const Vector3&, decimal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ray", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(rp_destruct<Vector3>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("ray", "vector point1", asOFFSET(Ray, point1));
	engine->RegisterObjectProperty("ray", "vector point2", asOFFSET(Ray, point2));
	engine->RegisterObjectProperty("ray", "float max_fraction", asOFFSET(Ray, maxFraction));

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

	engine->RegisterObjectType("transform", sizeof(Transform), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Transform>() | asOBJ_APP_CLASS_ALLFLOATS);
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

}
