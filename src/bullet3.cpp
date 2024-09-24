/* bullet3.cpp - bulletphysics integration code
 * At the moment, only contains a wrapper for bullet3's vector class and is pending expansion or outright replacement.
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

#include "bullet3.h"

static void Vector3DefaultConstructor(Vector3* self) {
	new (self) Vector3();
}

static void Vector3CopyConstructor(Vector3* self, const Vector3& other) {
	new (self) Vector3();
	self->setValue(other.x, other.y, other.z);
}

static void Vector3InitConstructor(float x, float y, float z, Vector3* self) {
	new (self) Vector3();
	self->setValue(x, y, z);
}

static void Vector3Destruct(Vector3* self) {
	self->~Vector3();
}

static Vector3& Vector3Assign(const Vector3& other, Vector3* self) {
	self->setValue(other.x, other.y, other.z);
	return *self;
}
static Vector3 Vector3OpAdd(Vector3* self, const Vector3& other) {
	return *self + other;
}
static Vector3 Vector3OpSub(Vector3* self, const Vector3& other) {
	return *self - other;
}
static Vector3 Vector3OpMul(Vector3* self, const Vector3& other) {
	return *self * other;
}
static Vector3 Vector3OpDiv(Vector3* self, const Vector3& other) {
	return *self / other;
}
static Vector3 Vector3OpMulN(Vector3* self, float other) {
	return *self * other;
}
static Vector3 Vector3OpDivN(Vector3* self, float other) {
	return *self / other;
}

void RegisterScriptBullet3(asIScriptEngine* engine) {
	engine->RegisterObjectType("vector", sizeof(Vector3), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<Vector3>() | asOBJ_APP_CLASS_ALLFLOATS);
	engine->RegisterObjectProperty("vector", "float x", asOFFSET(Vector3, x));
	engine->RegisterObjectProperty("vector", "float y", asOFFSET(Vector3, y));
	engine->RegisterObjectProperty("vector", "float z", asOFFSET(Vector3, z));
	engine->RegisterObjectBehaviour("vector", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(Vector3DefaultConstructor), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_CONSTRUCT, "void f(const vector &in)", asFUNCTION(Vector3CopyConstructor), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_CONSTRUCT, "void f(float, float = 0, float = 0)", asFUNCTION(Vector3InitConstructor), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectBehaviour("vector", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(Vector3Destruct), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("vector", "vector &opAssign(const vector &in)", asFUNCTION(Vector3Assign), asCALL_CDECL_OBJLAST);
	engine->RegisterObjectMethod("vector", "vector &opAddAssign(const vector &in)", asMETHODPR(Vector3, operator+=, (const Vector3&), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector &opSubAssign(const vector &in)", asMETHODPR(Vector3, operator-=, (const Vector3&), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector &opMulAssign(const float &in)", asMETHODPR(Vector3, operator*=, (const float&), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector &opDivAssign(const float&in)", asMETHODPR(Vector3, operator/=, (const float&), Vector3&), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool opEquals(const vector &in) const", asMETHODPR(Vector3, operator==, (const b3Vector3&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector opAdd(const vector &in) const", asFUNCTION(Vector3OpAdd), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opSub(const vector &in) const", asFUNCTION(Vector3OpSub), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opMul(const vector &in) const", asFUNCTION(Vector3OpMul), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opDiv(const vector &in) const", asFUNCTION(Vector3OpDiv), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opMul(float) const", asFUNCTION(Vector3OpMulN), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "vector opDiv(float) const", asFUNCTION(Vector3OpDivN), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("vector", "float length() const", asMETHOD(Vector3, length), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float length2() const", asMETHOD(Vector3, length2), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "bool get_is_zero() const property", asMETHOD(Vector3, isZero), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float dot(const vector&in) const", asMETHOD(Vector3, dot), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float distance(const vector&in) const", asMETHOD(Vector3, distance), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float distance2(const vector&in) const", asMETHOD(Vector3, distance2), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector cross(const vector&in) const", asMETHOD(Vector3, cross), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector& normalize()", asMETHOD(Vector3, normalize), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector normalized() const", asMETHOD(Vector3, normalized), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector absolute() const", asMETHOD(Vector3, absolute), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "vector rotate(const vector&in, const float) const", asMETHOD(Vector3, rotate), asCALL_THISCALL);
	engine->RegisterObjectMethod("vector", "float angle(const vector&in) const", asMETHOD(Vector3, angle), asCALL_THISCALL);
}
