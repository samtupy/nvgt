/* uuid.cpp - Poco::UUID wrapper for NVGT
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
#include <Poco/UUIDGenerator.h>

#include <cstring>

template <class T, typename... A>
void generic_construct(T* mem, A... args) { new (mem) T(args...); }
template <class T>
void generic_copy_construct(T* mem, const T& other) { new (mem) T(other); }
template <class T>
void generic_destruct(T* mem) { mem->~T(); }
template <class T>
int opCmp(const T& first, const T& second) {
	if (first < second)
		return -1;
	else if (first > second)
		return 1;
	else
		return 0;
}

void uuid_construct_string(void* mem, const std::string& str) {
	try {
		new (mem) Poco::UUID(str);
	} catch (const Poco::SyntaxException&) {
		new (mem) Poco::UUID();
	}
}

void uuid_construct_bytes(void* mem, const std::string& bytes) {
	if (bytes.size() >= 16)
		new (mem) Poco::UUID(bytes.data());
	else
		new (mem) Poco::UUID();
}

int uuid_get_version(const Poco::UUID& uuid) {
	return static_cast<int>(uuid.version());
}

std::string uuid_get_bytes(const Poco::UUID& uuid) {
	std::string result(16, '\0');
	uuid.copyTo(const_cast<char*>(result.data()));
	return result;
}

void uuid_set_bytes(Poco::UUID& uuid, const std::string& bytes) {
	if (bytes.size() >= 16)
		uuid.copyFrom(bytes.data());
}

void RegisterUUID(asIScriptEngine* engine) {
	engine->RegisterObjectType("uuid", sizeof(Poco::UUID), asOBJ_VALUE | asGetTypeTraits<Poco::UUID>());
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(generic_construct<Poco::UUID>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_CONSTRUCT, "void f(const string&in str)", asFUNCTION(uuid_construct_string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_CONSTRUCT, "void f(const uuid&in)", asFUNCTION(generic_copy_construct<Poco::UUID>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uuid", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(generic_destruct<Poco::UUID>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uuid", "uuid& opAssign(const uuid&in)", asMETHODPR(Poco::UUID, operator=, (const Poco::UUID&), Poco::UUID&), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string to_string() const", asMETHOD(Poco::UUID, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string get_str() const property", asMETHOD(Poco::UUID, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string opConv() const", asMETHOD(Poco::UUID, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "string opImplConv() const", asMETHOD(Poco::UUID, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "void parse(const string&in)", asMETHOD(Poco::UUID, parse), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "bool try_parse(const string&in)", asMETHOD(Poco::UUID, tryParse), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "int get_version() const property", asFUNCTION(uuid_get_version), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uuid", "int get_variant() const property", asMETHOD(Poco::UUID, variant), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "bool get_is_null() const property", asMETHOD(Poco::UUID, isNull), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "bool opEquals(const uuid&in) const", asMETHOD(Poco::UUID, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("uuid", "int opCmp(const uuid&in)", asFUNCTION(opCmp<Poco::UUID>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uuid", "string get_bytes() const", asFUNCTION(uuid_get_bytes), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uuid", "void set_bytes(const string&in)", asFUNCTION(uuid_set_bytes), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("uuid uuid_generate()", asMETHOD(Poco::UUIDGenerator, createOne), asCALL_THISCALL_ASGLOBAL, &Poco::UUIDGenerator::defaultGenerator());
	engine->RegisterGlobalFunction("uuid uuid_generate_random()", asMETHOD(Poco::UUIDGenerator, createRandom), asCALL_THISCALL_ASGLOBAL, &Poco::UUIDGenerator::defaultGenerator());
	engine->RegisterGlobalFunction("uuid uuid_generate_time()", asMETHOD(Poco::UUIDGenerator, create), asCALL_THISCALL_ASGLOBAL, &Poco::UUIDGenerator::defaultGenerator());
	engine->RegisterGlobalFunction("uuid uuid_create_from_name(const uuid&in, const string&in)", asMETHODPR(Poco::UUIDGenerator, createFromName, (const Poco::UUID&, const std::string&), Poco::UUID), asCALL_THISCALL_ASGLOBAL, &Poco::UUIDGenerator::defaultGenerator());
	engine->RegisterGlobalFunction("uuid uuid_namespace_dns()", asFUNCTION(Poco::UUID::dns), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid uuid_namespace_url()", asFUNCTION(Poco::UUID::uri), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid uuid_namespace_oid()", asFUNCTION(Poco::UUID::oid), asCALL_CDECL);
	engine->RegisterGlobalFunction("uuid uuid_namespace_x500()", asFUNCTION(Poco::UUID::x500), asCALL_CDECL);
}