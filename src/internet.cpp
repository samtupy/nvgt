/* internet.cpp - code for wrapping http, ftp and more mostly wrapping PocoNet
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
#include <obfuscate.h>
#include <Poco/Format.h>
#include <Poco/URI.h>
#include <Poco/URIStreamOpener.h>
#include <Poco/Net/MessageHeader.h>
#include "datastreams.h"
#include "internet.h"
#include "nvgt.h"

using namespace std;
using namespace Poco;
using namespace Poco::Net;

string url_encode(const string& url, const string& reserved) {
	string result;
	URI::encode(url, reserved, result);
	return result;
}
string url_decode(const string& url, bool plus_as_space) {
	string result;
	URI::decode(url, result, plus_as_space);
	return result;
}

template <class T> void generic_construct(T* mem) { new (mem) T(); }
template <class T> void generic_copy_construct(T* mem, const T& other) { new (mem) T(other); }
template <class T> void generic_destruct(T* mem) { mem->~T(); }

template <class T> void RegisterNameValueCollection(asIScriptEngine* engine, const string& type, bool make_class = false) {
	if (make_class) {
		engine->RegisterObjectType(type.c_str(), sizeof(T), asOBJ_VALUE | asGetTypeTraits<T>());
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(generic_construct<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_CONSTRUCT, format("void f(const %s&in)", type).c_str(), asFUNCTION(generic_copy_construct<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_DESTRUCT, "void f()", asFUNCTION(generic_destruct<T>), asCALL_CDECL_OBJFIRST);
	}
	engine->RegisterObjectMethod(type.c_str(), "const string& get_opIndex(const string&in) const property", asMETHOD(T, operator[]), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_opIndex(const string&in, const string&in) property", asMETHOD(T, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set(const string&in, const string&in)", asMETHOD(T, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void add(const string&in, const string&in)", asMETHOD(T, add), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get(const string&in, const string&in = \"\") const", asMETHODPR(T, get, (const string&, const string&) const, const string&), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool exists(const string&in) const", asMETHOD(T, has), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool empty() const", asMETHOD(T, empty), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "uint64 size() const", asMETHOD(T, size), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void erase(const string&in)", asMETHOD(T, erase), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void clear()", asMETHOD(T, clear), asCALL_THISCALL);
}

void RegisterInternet(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalFunction(_O("string url_encode(const string&in, const string&in = \"\")"), asFUNCTION(url_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string url_decode(const string&in, bool = true)"), asFUNCTION(url_decode), asCALL_CDECL);
	RegisterNameValueCollection<NameValueCollection>(engine, "name_value_collection", true);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_NET);
}
