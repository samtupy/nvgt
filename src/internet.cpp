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
#include <Poco/Net/HTTPMessage.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPRequest.h>
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
template <class T, class P> void RegisterHTTPMessage(asIScriptEngine* engine, const string& type, const string& parent) {
	RegisterMessageHeader<T, P>(engine, type, parent);
	engine->RegisterObjectMethod(type.c_str(), "void set_version(const string&in) property", asMETHOD(T, setVersion), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_version() const property", asMETHOD(T, getVersion), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_content_length(int64) property", asMETHOD(T, setContentLength64), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int64 get_content_length() const property", asMETHOD(T, getContentLength64), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_has_content_length() const property", asMETHOD(T, hasContentLength), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_transfer_encoding(const string&in) property", asMETHOD(T, setTransferEncoding), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string get_transfer_encoding() const property", asMETHOD(T, getTransferEncoding), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_chunked_transfer_encoding(bool) property", asMETHOD(T, setChunkedTransferEncoding), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_chunked_transfer_encoding() const property", asMETHOD(T, getChunkedTransferEncoding), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_content_type(const string&in) property", asMETHODPR(T, setContentType, (const string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string get_content_type() const property", asMETHOD(T, getContentType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_keep_alive(bool) property", asMETHOD(T, setKeepAlive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_keep_alive() const property", asMETHOD(T, getKeepAlive), asCALL_THISCALL);
}
template <class T, class P> void RegisterHTTPRequest(asIScriptEngine* engine, const string& type, const string& parent) {
	RegisterHTTPMessage<T, P>(engine, type, parent);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, const string&in, const string&in = HTTP_1_1)", type).c_str(), asFUNCTION((generic_factory<T, const string&, const string&, const string&>)), asCALL_CDECL);
	engine->RegisterObjectMethod(type.c_str(), "void set_method(const string&in) property", asMETHOD(T, setMethod), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_method() const property", asMETHOD(T, getMethod), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_uri(const string&in) property", asMETHOD(T, setURI), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_uri() const property", asMETHOD(T, getURI), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_host(const string&in) property", asMETHODPR(T, setHost, (const string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_host(const string&in, uint16) property", asMETHODPR(T, setHost, (const string&, UInt16), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_host() const property", asMETHOD(T, getHost), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_cookies(const name_value_collection&)", asMETHOD(T, setCookies), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_cookies(name_value_collection&) const", asMETHOD(T, getCookies), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_has_credentials() const property", asMETHOD(T, hasCredentials), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_credentials(string&, string&) const", asMETHODPR(T, getCredentials, (string&, string&) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_credentials(const string&in, const string&in)", asMETHODPR(T, setCredentials, (const string&, const string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove_credentials()", asMETHOD(T, removeCredentials), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_expect_continue() const property", asMETHOD(T, getExpectContinue), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_expect_continue(bool) property", asMETHOD(T, setExpectContinue), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_has_proxy_credentials() const property", asMETHOD(T, hasProxyCredentials), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_proxy_credentials(string&, string&) const", asMETHOD(T, getProxyCredentials), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_proxy_credentials(const string&in, const string&in)", asMETHOD(T, setProxyCredentials), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove_proxy_credentials()", asMETHOD(T, removeProxyCredentials), asCALL_THISCALL);
}

void RegisterInternet(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalProperty("const string HTTP_1_0", (void*)&HTTPMessage::HTTP_1_0);
	engine->RegisterGlobalProperty("const string HTTP_1_1", (void*)&HTTPMessage::HTTP_1_1);
	engine->RegisterGlobalProperty("const string HTTP_IDENTITY_TRANSFER_ENCODING", (void*)&HTTPMessage::IDENTITY_TRANSFER_ENCODING);
	engine->RegisterGlobalProperty("const string HTTP_CHUNKED_TRANSFER_ENCODING", (void*)&HTTPMessage::CHUNKED_TRANSFER_ENCODING);
	engine->RegisterGlobalProperty("const int HTTP_UNKNOWN_CONTENT_LENGTH", (void*)&HTTPMessage::UNKNOWN_CONTENT_LENGTH);
	engine->RegisterGlobalProperty("const string HTTP_UNKNOWN_CONTENT_TYPE", (void*)&HTTPMessage::UNKNOWN_CONTENT_TYPE);
	engine->RegisterGlobalFunction(_O("string url_encode(const string&in, const string&in = \"\")"), asFUNCTION(url_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string url_decode(const string&in, bool = true)"), asFUNCTION(url_decode), asCALL_CDECL);
	RegisterNameValueCollection<NameValueCollection>(engine, "name_value_collection");
	RegisterMessageHeader<MessageHeader, NameValueCollection>(engine, "internet_message_header", "name_value_collection");
	RegisterHTTPRequest<HTTPRequest, MessageHeader>(engine, "http_request", "internet_message_header");
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_NET);
}
