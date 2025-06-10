/* uuid.cpp - Poco UUID wrapper implementation for NVGT
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

#include "uuid.h"

#include <Poco/Exception.h>

#include <cstring>

uuid::uuid() : m_refcount(1), m_uuid(new Poco::UUID()) {}

uuid::uuid(Poco::SharedPtr<Poco::UUID> u) : m_refcount(1), m_uuid(std::move(u)) {}

uuid::uuid(const std::string& str) : m_refcount(1), m_uuid(new Poco::UUID()) {
	try {
		m_uuid->parse(str);
	} catch (const Poco::Exception&) {
		// Leave as nil UUID if parsing fails
	}
}

uuid::uuid(const uuid& other) : m_refcount(1), m_uuid(new Poco::UUID(*other.m_uuid)) {}

void uuid::add_ref() {
	asAtomicInc(m_refcount);
}

void uuid::release() {
	if (asAtomicDec(m_refcount) < 1)
		delete this;
}

uuid& uuid::operator=(const uuid& other) {
	m_uuid = Poco::SharedPtr<Poco::UUID>(new Poco::UUID(*other.m_uuid));
	return *this;
}

std::string uuid::to_string() const {
	return m_uuid->toString();
}

void uuid::parse(const std::string& str) {
	m_uuid->parse(str);
}

bool uuid::try_parse(const std::string& str) {
	return m_uuid->tryParse(str);
}

int uuid::get_version() const {
	return static_cast<int>(m_uuid->version());
}

int uuid::get_variant() const {
	return m_uuid->variant();
}

bool uuid::is_null() const {
	return m_uuid->isNull();
}

bool uuid::operator==(const uuid& other) const {
	return *m_uuid == *other.m_uuid;
}

bool uuid::operator!=(const uuid& other) const {
	return *m_uuid != *other.m_uuid;
}

bool uuid::operator<(const uuid& other) const {
	return *m_uuid < *other.m_uuid;
}

bool uuid::operator<=(const uuid& other) const {
	return *m_uuid <= *other.m_uuid;
}

bool uuid::operator>(const uuid& other) const {
	return *m_uuid > *other.m_uuid;
}

bool uuid::operator>=(const uuid& other) const {
	return *m_uuid >= *other.m_uuid;
}

std::string uuid::get_bytes() const {
	std::string result(16, '\0');
	m_uuid->copyTo(const_cast<char*>(result.data()));
	return result;
}

void uuid::set_bytes(const std::string& bytes) {
	if (bytes.size() >= 16)
		m_uuid->copyFrom(bytes.data());
}

uuid* uuid_factory() {
	return new uuid();
}

uuid* uuid_factory_string(const std::string& str) {
	return new uuid(str);
}

std::string uuid_generate() {
	return Poco::UUIDGenerator::defaultGenerator().createOne().toString();
}

std::string uuid_generate_random() {
	return Poco::UUIDGenerator::defaultGenerator().createRandom().toString();
}

std::string uuid_generate_time() {
	try {
		return Poco::UUIDGenerator::defaultGenerator().create().toString();
	} catch (const Poco::Exception&) {
		// Fall back to random if time-based fails (no MAC address)
		return uuid_generate_random();
	}
}

uuid* uuid_create() {
	return new uuid(new Poco::UUID(Poco::UUIDGenerator::defaultGenerator().createOne()));
}

uuid* uuid_create_random() {
	return new uuid(new Poco::UUID(Poco::UUIDGenerator::defaultGenerator().createRandom()));
}

uuid* uuid_create_time() {
	try {
		return new uuid(new Poco::UUID(Poco::UUIDGenerator::defaultGenerator().create()));
	} catch (const Poco::Exception&) {
		// Fall back to random if time-based fails
		return new uuid(new Poco::UUID(Poco::UUIDGenerator::defaultGenerator().createRandom()));
	}
}

uuid* uuid_create_from_name(const uuid& namespace_id, const std::string& name) {
	return new uuid(new Poco::UUID(Poco::UUIDGenerator::defaultGenerator().createFromName(*namespace_id.m_uuid, name)));
}

int uuid_compare(const uuid* a, const uuid* b) {
	if (!a || !b) return 0;
	if (*a < *b) return -1;
	if (*a > *b) return 1;
	return 0;
}

uuid* uuid_namespace_dns() {
	return new uuid(new Poco::UUID(Poco::UUID::dns()));
}

uuid* uuid_namespace_url() {
	return new uuid(new Poco::UUID(Poco::UUID::uri()));
}

uuid* uuid_namespace_oid() {
	return new uuid(new Poco::UUID(Poco::UUID::oid()));
}

uuid* uuid_namespace_x500() {
	return new uuid(new Poco::UUID(Poco::UUID::x500()));
}

void RegisterUUID(asIScriptEngine* engine) {
	engine->RegisterObjectType("uuid", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_FACTORY, "uuid@ f()", asFUNCTION(uuid_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_FACTORY, "uuid@ f(const string &in)", asFUNCTION(uuid_factory_string), asCALL_CDECL);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_ADDREF, "void f()", asMETHOD(uuid, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_RELEASE, "void f()", asMETHOD(uuid, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "uuid& opAssign(const uuid &in)", asMETHOD(uuid, operator=), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string to_string() const", asMETHOD(uuid, to_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string get_str() const property", asMETHOD(uuid, str), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string opConv() const", asMETHOD(uuid, to_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string opImplConv() const", asMETHOD(uuid, to_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "void parse(const string &in)", asMETHOD(uuid, parse), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "bool try_parse(const string &in)", asMETHOD(uuid, try_parse), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "int get_version() const property", asMETHOD(uuid, get_version), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "int get_variant() const property", asMETHOD(uuid, get_variant), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "bool get_is_null() const property", asMETHOD(uuid, is_null), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "bool opEquals(const uuid &in) const", asMETHOD(uuid, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "int opCmp(const uuid &in) const", asFUNCTION(uuid_compare), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uuid", "string get_bytes() const", asMETHOD(uuid, get_bytes), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "void set_bytes(const string &in)", asMETHOD(uuid, set_bytes), asCALL_THISCALL);
	engine->RegisterGlobalFunction("string uuid_generate()", asFUNCTION(uuid_generate), asCALL_CDECL);
	engine->RegisterGlobalFunction("string uuid_generate_random()", asFUNCTION(uuid_generate_random), asCALL_CDECL);
	engine->RegisterGlobalFunction("string uuid_generate_time()", asFUNCTION(uuid_generate_time), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_create()", asFUNCTION(uuid_create), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_create_random()", asFUNCTION(uuid_create_random), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_create_time()", asFUNCTION(uuid_create_time), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_create_from_name(const uuid &in, const string &in)", asFUNCTION(uuid_create_from_name), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_namespace_dns()", asFUNCTION(uuid_namespace_dns), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_namespace_url()", asFUNCTION(uuid_namespace_url), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_namespace_oid()", asFUNCTION(uuid_namespace_oid), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid@ uuid_namespace_x500()", asFUNCTION(uuid_namespace_x500), asCALL_CDECL);
}