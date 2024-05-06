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
#include "pocostuff.h" // angelscript_refcounted

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
template <class T, typename... A> void* generic_factory(A... args) {
	return new(angelscript_refcounted_create<T>()) T(args...);
}

// We will need to wrap any functions that handle std iostreams.
template <class T> bool message_header_write(MessageHeader* h, datastream* ds) {
	if (!ds || !ds->get_ostr()) return false;
	try {
		h->write(*ds->get_ostr());
	} catch (Exception&) { return false; }
	return true;
}
template <class T> bool message_header_read(MessageHeader* h, datastream* ds) {
	if (!ds || !ds->get_istr()) return false;
	try {
		h->read(*ds->get_istr());
	} catch (Exception&) { return false; }
	return true;
}

template <class T> void RegisterNameValueCollection(asIScriptEngine* engine, const string& type) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f()", type).c_str(), asFUNCTION(generic_factory<T>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const %s&in)", type, type).c_str(), asFUNCTION((generic_factory<T, const T&>)), asCALL_CDECL);
	engine->RegisterObjectMethod(type.c_str(), format("%s& opAssign(const %s&in)", type, type).c_str(), asMETHODPR(T, operator=, (const T&), T&), asCALL_THISCALL);
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
template <class T, class P> void RegisterMessageHeader(asIScriptEngine* engine, const string& type, const string& parent) {
	RegisterNameValueCollection<T>(engine, type);
	engine->RegisterObjectMethod(parent.c_str(), format("%s@ opCast()", type).c_str(), asFUNCTION((angelscript_refcounted_refcast<P, T>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), format("%s@ opImplCast()", parent).c_str(), asFUNCTION((angelscript_refcounted_refcast<T, P>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool write(datastream@) const", asFUNCTION(message_header_write<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool read(datastream@)", asFUNCTION(message_header_read<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_auto_decode() const property", asMETHOD(T, getAutoDecode), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_auto_decode(bool) property", asMETHOD(T, setAutoDecode), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string get_decoded(const string&in, const string&in = \"\")", asMETHODPR(T, getDecoded, (const std::string&, const std::string&) const, std::string), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_field_limit() const property", asMETHOD(T, getFieldLimit), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_field_limit(int) property", asMETHOD(T, setFieldLimit), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_name_length_limit() const property", asMETHOD(T, getNameLengthLimit), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_name_length_limit(int) property", asMETHOD(T, setNameLengthLimit), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_value_length_limit() const property", asMETHOD(T, getValueLengthLimit), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_value_length_limit(int) property", asMETHOD(T, setValueLengthLimit), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool has_token(const string&in, const string&in)", asMETHOD(T, hasToken), asCALL_THISCALL);
}

void RegisterInternet(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalFunction(_O("string url_encode(const string&in, const string&in = \"\")"), asFUNCTION(url_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string url_decode(const string&in, bool = true)"), asFUNCTION(url_decode), asCALL_CDECL);
	RegisterNameValueCollection<NameValueCollection>(engine, "name_value_collection");
	RegisterMessageHeader<MessageHeader, NameValueCollection>(engine, "internet_message_header", "name_value_collection");
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_NET);
}
