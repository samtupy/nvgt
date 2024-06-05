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
#include <Poco/NullStream.h>
#include <Poco/StreamCopier.h>
#include <Poco/URI.h>
#include <Poco/URIStreamOpener.h>
#include <Poco/Net/AcceptCertificateHandler.h>
#include <Poco/Net/Context.h>
#include <Poco/Net/FTPClientSession.h>
#include <Poco/Net/HTTPClientSession.h>
#include <Poco/Net/HTTPCredentials.h>
#include <Poco/Net/HTTPMessage.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPSClientSession.h>
#include <Poco/Net/MessageHeader.h>
#include <Poco/Net/SSLManager.h>
#include <scriptarray.h>
#include <scriptdictionary.h>
#include "datastreams.h"
#include "internet.h"
#include "nvgt.h"
#include "pocostuff.h" // angelscript_refcounted
#include "version.h"

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
template<class T> datastream* http_client_send_request(T* s, HTTPRequest& req, f_streamargs) {
	datastream* ds = new datastream(&s->sendRequest(req), p_streamargs);
	ds->no_close = true;
	return ds;
}
template<class T> datastream* http_client_receive_response(T* s, HTTPResponse& response, f_streamargs) {
	datastream* ds = new datastream(&s->receiveResponse(response), p_streamargs);
	ds->no_close = true;
	return ds;
}
template<class T> datastream* ftp_client_begin_download(T* s, const std::string& path, f_streamargs) {
	datastream* ds = new datastream(&s->beginDownload(path), p_streamargs);
	ds->no_close = true;
	return ds;
}
template<class T> datastream* ftp_client_begin_upload(T* s, const std::string& path, f_streamargs) {
	datastream* ds = new datastream(&s->beginUpload(path), p_streamargs);
	ds->no_close = true;
	return ds;
}
template<class T> datastream* ftp_client_begin_list(T* s, const std::string& path, bool extended, f_streamargs) {
	datastream* ds = new datastream(&s->beginList(path, extended), p_streamargs);
	ds->no_close = true;
	return ds;
}

// Some functions for name_value_collection and derivatives that we can't directly wrap.
template <class T> T* name_value_collection_list_factory(asBYTE* buffer) {
	// This is the first time I've written a repeating list factory wrapper for use with Angelscript, so it is heavily based on the example in asAddon/src/scriptdictionary.cpp but omitting the reference type checks.
	T* nvc = new (angelscript_refcounted_create<T>()) T();
	asUINT length = *(asUINT*)buffer;
	buffer += 4;
	while (length--) {
		if (asPWORD(buffer) & 0x3)
			buffer += 4 - (asPWORD(buffer) & 0x3); // No idea if we need this while only working with strings.
		std::string name = *(std::string*) buffer;
		buffer += sizeof(std::string);
		std::string value = *(std::string*) buffer;
		buffer += sizeof(std::string);
		nvc->add(name, value);
	}
	return nvc;
}
template <class T> const string& name_value_collection_name_at(T* nvc, unsigned int index) {
	if (index >= nvc->size()) throw RangeException(format("index %u into name_value_collection out of bounds (contains %z elements)", index, nvc->size()));
	return (nvc->begin() + index)->first;
}
template <class T> const string& name_value_collection_value_at(T* nvc, unsigned int index) {
	if (index >= nvc->size()) throw RangeException(format("index %u into name_value_collection out of bounds (contains %z elements)", index, nvc->size()));
	return (nvc->begin() + index)->second;
}

template <class T> void RegisterNameValueCollection(asIScriptEngine* engine, const string& type) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f()", type).c_str(), asFUNCTION(angelscript_refcounted_factory<T>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const %s&in)", type, type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const T&>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_LIST_FACTORY, format("%s@ f(int&in) {repeat {string, string}}", type).c_str(), asFUNCTION(name_value_collection_list_factory<T>), asCALL_CDECL);
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
	engine->RegisterObjectMethod(type.c_str(), "const string& name_at(uint)", asFUNCTION(name_value_collection_name_at<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "const string& value_at(uint)", asFUNCTION(name_value_collection_value_at<T>), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, const string&in, const string&in = HTTP_1_1)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, const string&, const string&>)), asCALL_CDECL);
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
template <class T, class P> void RegisterHTTPResponse(asIScriptEngine* engine, const string& type, const string& parent) {
	RegisterHTTPMessage<T, P>(engine, type, parent);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(http_status)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, HTTPResponse::HTTPStatus>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(http_status, const string&in)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, HTTPResponse::HTTPStatus, const string&>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, http_status, const string&in)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, HTTPResponse::HTTPStatus, const string&>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, http_status)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, HTTPResponse::HTTPStatus>)), asCALL_CDECL);
	engine->RegisterObjectMethod(type.c_str(), "void set_status(http_status) property", asMETHODPR(T, setStatus, (HTTPResponse::HTTPStatus), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "http_status get_status() const property", asMETHOD(T, getStatus), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_status(const string&in)", asMETHODPR(T, setStatus, (const string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_reason(const string&in) property", asMETHOD(T, setReason), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_reason() const property", asMETHOD(T, getReason), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_status_and_reason(http_status, const string&in)", asMETHODPR(T, setStatusAndReason, (HTTPResponse::HTTPStatus, const string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_status_and_reason(http_status)", asMETHODPR(T, setStatusAndReason, (HTTPResponse::HTTPStatus), void), asCALL_THISCALL);
}
template <class T> void RegisterHTTPSession(asIScriptEngine* engine, const string& type) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	engine->RegisterObjectMethod(type.c_str(), "void set_keep_alive(bool) property", asMETHOD(T, setKeepAlive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_keep_alive() const property", asMETHOD(T, getKeepAlive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_connected() const property", asMETHOD(T, connected), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void abort()", asMETHOD(T, abort), asCALL_THISCALL);
}
template <class T> void RegisterHTTPClientSession(asIScriptEngine* engine, const string& type) {
	RegisterHTTPSession<T>(engine, type);
	if constexpr(std::is_same<T, HTTPSClientSession>::value) engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, uint16 = 443)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, UInt16>)), asCALL_CDECL);
	else engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, uint16 = 80)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, UInt16>)), asCALL_CDECL);
	engine->RegisterObjectMethod(type.c_str(), "void set_host(const string&in) property", asMETHOD(T, setHost), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_host() const property", asMETHOD(T, getHost), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_port(uint16) property", asMETHOD(T, setPort), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "uint16 get_port() const property", asMETHOD(T, getPort), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ send_request(http_request&, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(http_client_send_request<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ receive_response(http_response&, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(http_client_receive_response<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool peek_response(http_response&)", asMETHOD(T, peekResponse), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void flush_request()", asMETHOD(T, flushRequest), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void reset()", asMETHOD(T, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_secure() const property", asMETHOD(T, secure), asCALL_THISCALL);
}
template <class T> void RegisterFTPClientSession(asIScriptEngine* engine, const std::string& type) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(uint16 = 0)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, UInt16>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in, uint16 = 21, const string&in = \"\", const string&in = \"\", uint16 = 0)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, UInt16, const string&, const string&, UInt16>)), asCALL_CDECL);
	engine->RegisterObjectMethod(type.c_str(), "void set_passive(bool, bool = true)", asMETHOD(T, setPassive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_passive() const property", asMETHOD(T, getPassive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void open(const string&in, uint16, const string&in = \"\", const string&in = \"\")", asMETHOD(T, open), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void login(const string&in, const string&in)", asMETHOD(T, login), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void logout()", asMETHOD(T, logout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void close()", asMETHOD(T, close), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string system_type()", asMETHOD(T, systemType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_file_type(ftp_file_type)", asMETHOD(T, setFileType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "ftp_file_type get_file_type() const property", asMETHOD(T, getFileType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_working_directory(const string&in)", asMETHOD(T, setWorkingDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string get_working_directory()", asMETHOD(T, getWorkingDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void cdup()", asMETHOD(T, cdup), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void rename(const string&in, const string&in)", asMETHOD(T, rename), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove(const string&in)", asMETHOD(T, remove), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void create_directory(const string&in)", asMETHOD(T, createDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove_directory(const string&in)", asMETHOD(T, removeDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ begin_download(const string&in, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(ftp_client_begin_download<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void end_download()", asMETHOD(T, endDownload), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ begin_upload(const string&in, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(ftp_client_begin_upload<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void end_upload()", asMETHOD(T, endUpload), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ begin_list(const string&in = \"\", bool = false, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(ftp_client_begin_list<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void end_list()", asMETHOD(T, endList), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void abort()", asMETHOD(T, abort), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int send_command(const string&in, string&)", asMETHODPR(T, sendCommand, (const string&, string&), int), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int send_command(const string&in, const string&in, string&)", asMETHODPR(T, sendCommand, (const string&, const string&, string&), int), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_open() const property", asMETHOD(T, isOpen), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_logged_in() const property", asMETHOD(T, isLoggedIn), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_secure() const property", asMETHOD(T, isSecure), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_welcome_message() const property", asMETHOD(T, welcomeMessage), asCALL_THISCALL);
}

// NVGT's highest level HTTP. The following code will likely be rewritten once after we write the http class, which will be the middle-level http support. For now this is being rushed to fix an issue regarding the removal of curl and the url_get/post methods in bgt_compat.nvgt. The original code was sourced from Poco's HTTPSUriStreamOpener.
string url_request(const string& method, const string& url, const string& data, HTTPResponse* resp) {
	URI u(url);
	if (u.getScheme() != "http" && u.getScheme() != "https") return "";
	string user, password;
	bool authorize = false;
	bool delete_response = resp == nullptr; // In this case we create our own response object and must delete it when finished.
	HTTPClientSession* http = NULL;
	if (!resp) resp = new HTTPResponse;
	int tries = 10;
	while (tries) {
		tries--;
		try {
			string path = u.getPathAndQuery();
			if (path.empty()) path = "/";
			HTTPRequest req(method, path, HTTPMessage::HTTP_1_1);
			req.setContentLength(data.length());
			req.setContentType("application/x-www-form-urlencoded");
			if (!http) http = u.getScheme() == "http"? new HTTPClientSession(u.getHost(), u.getPort()) : new HTTPSClientSession(u.getHost(), u.getPort());
			if (authorize) {
				HTTPCredentials::extractCredentials(u, user, password);
				HTTPCredentials cred(user, password);
				cred.authenticate(req, *resp);
			}
			req.set("User-Agent"s, "nvgt "s + NVGT_VERSION);
			std::ostream& ostr = http->sendRequest(req);
			ostr << data;
			std::istream& istr = http->receiveResponse(*resp);
			bool moved = (resp->getStatus() == HTTPResponse::HTTP_MOVED_PERMANENTLY || resp->getStatus() == HTTPResponse::HTTP_FOUND || resp->getStatus() == HTTPResponse::HTTP_SEE_OTHER || resp->getStatus() == HTTPResponse::HTTP_TEMPORARY_REDIRECT);
			if (moved) {
				u.resolve(resp->get("Location"));
				if (!user.empty()) {
					u.setUserInfo(format("%s:%s", user, password));
					authorize = false;
				}
				delete http;
				http = nullptr;
				continue; // Try again with the new URI
			} else if (resp->getStatus() == HTTPResponse::HTTP_UNAUTHORIZED && !authorize) {
				authorize = true;
				NullOutputStream null;
				StreamCopier::copyStream(istr, null);
				continue;
			} else {
				string result;
				StreamCopier::copyToString(istr, result);
				delete http;
				if (delete_response) delete resp;
				return result;
			}
		} catch(Exception& e) {
			if (delete_response) delete resp;
			return "";
		}
	}
	if (http) delete http;
	if (delete_response) delete resp;
	return "";
}
string url_get(const string& url, HTTPResponse* resp) { return url_request(HTTPRequest::HTTP_GET, url, "", resp); }
string url_post(const string& url, const string& data, HTTPResponse* resp) { return url_request(HTTPRequest::HTTP_POST, url, data, resp); }

void RegisterInternet(asIScriptEngine* engine) {
	SSLManager::instance().initializeClient(NULL, new AcceptCertificateHandler(false), new Context(Context::TLS_CLIENT_USE, ""));
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	map<string, int> http_statuses({
		{"HTTP_CONTINUE", 100}, {"HTTP_SWITCHING_PROTOCOLS", 101}, {"HTTP_PROCESSING", 102}, {"HTTP_OK", 200}, {"HTTP_CREATED", 201}, {"HTTP_ACCEPTED", 202}, {"HTTP_NONAUTHORITATIVE", 203}, {"HTTP_NO_CONTENT", 204}, {"HTTP_RESET_CONTENT", 205}, {"HTTP_PARTIAL_CONTENT", 206}, {"HTTP_MULTI_STATUS", 207}, {"HTTP_ALREADY_REPORTED", 208}, {"HTTP_IM_USED", 226},
		{"HTTP_MULTIPLE_CHOICES", 300}, {"HTTP_MOVED_PERMANENTLY", 301}, {"HTTP_FOUND", 302}, {"HTTP_SEE_OTHER", 303}, {"HTTP_NOT_MODIFIED", 304}, {"HTTP_USE_PROXY", 305}, {"HTTP_TEMPORARY_REDIRECT", 307}, {"HTTP_PERMANENT_REDIRECT", 308},
		{"HTTP_BAD_REQUEST", 400}, {"HTTP_UNAUTHORIZED", 401}, {"HTTP_PAYMENT_REQUIRED", 402}, {"HTTP_FORBIDDEN", 403}, {"HTTP_NOT_FOUND", 404}, {"HTTP_METHOD_NOT_ALLOWED", 405}, {"HTTP_NOT_ACCEPTABLE", 406}, {"HTTP_PROXY_AUTHENTICATION_REQUIRED", 407}, {"HTTP_REQUEST_TIMEOUT", 408}, {"HTTP_CONFLICT", 409}, {"HTTP_GONE", 410}, {"HTTP_LENGTH_REQUIRED", 411}, {"HTTP_PRECONDITION_FAILED", 412}, {"HTTP_REQUEST_ENTITY_TOO_LARGE", 413}, {"HTTP_REQUEST_URI_TOO_LONG", 414}, {"HTTP_UNSUPPORTED_MEDIA_TYPE", 415}, {"HTTP_REQUESTED_RANGE_NOT_SATISFIABLE", 416}, {"HTTP_EXPECTATION_FAILED", 417}, {"HTTP_IM_A_TEAPOT", 418}, {"HTTP_ENCHANCE_YOUR_CALM", 420}, {"HTTP_MISDIRECTED_REQUEST", 421}, {"HTTP_UNPROCESSABLE_ENTITY", 422}, {"HTTP_LOCKED", 423}, {"HTTP_FAILED_DEPENDENCY", 424}, {"HTTP_TOO_EARLY", 425}, {"HTTP_UPGRADE_REQUIRED", 426}, {"HTTP_PRECONDITION_REQUIRED", 428}, {"HTTP_TOO_MANY_REQUESTS", 429}, {"HTTP_REQUEST_HEADER_FIELDS_TOO_LARGE", 431}, {"HTTP_UNAVAILABLE_FOR_LEGAL_REASONS", 451},
		{"HTTP_INTERNAL_SERVER_ERROR", 500}, {"HTTP_NOT_IMPLEMENTED", 501}, {"HTTP_BAD_GATEWAY", 502}, {"HTTP_SERVICE_UNAVAILABLE", 503}, {"HTTP_GATEWAY_TIMEOUT", 504}, {"HTTP_VERSION_NOT_SUPPORTED", 505}, {"HTTP_VARIANT_ALSO_NEGOTIATES", 506}, {"HTTP_INSUFFICIENT_STORAGE", 507}, {"HTTP_LOOP_DETECTED", 508}, {"HTTP_NOT_EXTENDED", 510}, {"HTTP_NETWORK_AUTHENTICATION_REQUIRED", 511}
	});
	engine->RegisterEnum("http_status");
	for (const auto& k : http_statuses) engine->RegisterEnumValue("http_status", k.first.c_str(), k.second);
	engine->RegisterGlobalFunction("string http_status_reason(http_status)", asFUNCTION(HTTPResponse::getReasonForStatus), asCALL_CDECL);
	engine->RegisterGlobalProperty("const string HTTP_1_0", (void*)&HTTPMessage::HTTP_1_0);
	engine->RegisterGlobalProperty("const string HTTP_1_1", (void*)&HTTPMessage::HTTP_1_1);
	engine->RegisterGlobalProperty("const string HTTP_IDENTITY_TRANSFER_ENCODING", (void*)&HTTPMessage::IDENTITY_TRANSFER_ENCODING);
	engine->RegisterGlobalProperty("const string HTTP_CHUNKED_TRANSFER_ENCODING", (void*)&HTTPMessage::CHUNKED_TRANSFER_ENCODING);
	engine->RegisterGlobalProperty("const int HTTP_UNKNOWN_CONTENT_LENGTH", (void*)&HTTPMessage::UNKNOWN_CONTENT_LENGTH);
	engine->RegisterGlobalProperty("const string HTTP_UNKNOWN_CONTENT_TYPE", (void*)&HTTPMessage::UNKNOWN_CONTENT_TYPE);
	engine->RegisterGlobalProperty("const string HTTP_GET", (void*)&HTTPRequest::HTTP_GET);
	engine->RegisterGlobalProperty("const string HTTP_POST", (void*)&HTTPRequest::HTTP_POST);
	engine->RegisterGlobalProperty("const string HTTP_HEAD", (void*)&HTTPRequest::HTTP_HEAD);
	engine->RegisterGlobalProperty("const string HTTP_PUT", (void*)&HTTPRequest::HTTP_PUT);
	engine->RegisterGlobalProperty("const string HTTP_DELETE", (void*)&HTTPRequest::HTTP_DELETE);
	engine->RegisterGlobalProperty("const string HTTP_PATCH", (void*)&HTTPRequest::HTTP_PATCH);
	engine->RegisterGlobalProperty("const string HTTP_OPTIONS", (void*)&HTTPRequest::HTTP_OPTIONS);
	engine->RegisterEnum("ftp_file_type");
	engine->RegisterEnumValue("ftp_file_type", "FTP_FILE_TYPE_TEXT", FTPClientSession::TYPE_TEXT);
	engine->RegisterEnumValue("ftp_file_type", "FTP_FILE_TYPE_BINARY", FTPClientSession::TYPE_BINARY);
	engine->RegisterGlobalFunction(_O("string url_encode(const string&in, const string&in = \"\")"), asFUNCTION(url_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string url_decode(const string&in, bool = true)"), asFUNCTION(url_decode), asCALL_CDECL);
	RegisterNameValueCollection<NameValueCollection>(engine, "name_value_collection");
	RegisterMessageHeader<MessageHeader, NameValueCollection>(engine, "internet_message_header", "name_value_collection");
	RegisterHTTPRequest<HTTPRequest, MessageHeader>(engine, "http_request", "internet_message_header");
	RegisterHTTPResponse<HTTPResponse, MessageHeader>(engine, "http_response", "internet_message_header");
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_NET);
	RegisterHTTPClientSession<HTTPClientSession>(engine, "http_client");
	RegisterHTTPClientSession<HTTPSClientSession>(engine, "https_client");
	engine->RegisterObjectMethod("http_client", "https_client@ opCast()", asFUNCTION((angelscript_refcounted_refcast<HTTPClientSession, HTTPSClientSession>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("https_client", "http_client@ opImplCast()", asFUNCTION((angelscript_refcounted_refcast<HTTPSClientSession, HTTPClientSession>)), asCALL_CDECL_OBJFIRST);
	RegisterFTPClientSession<FTPClientSession>(engine, "ftp_client");
	engine->RegisterGlobalFunction("string url_request(const string&in, const string&in, const string&in = \"\", http_response&out = void)", asFUNCTION(url_request), asCALL_CDECL);
	engine->RegisterGlobalFunction("string url_get(const string&in, http_response&out = void)", asFUNCTION(url_get), asCALL_CDECL);
	engine->RegisterGlobalFunction("string url_post(const string&in, const string&in, http_response&out = void)", asFUNCTION(url_post), asCALL_CDECL);
}
