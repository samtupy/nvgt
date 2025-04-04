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

#include <atomic>
#include <string>
#include <obfuscate.h>
#include <Poco/Format.h>
#include <Poco/NullStream.h>
#include <Poco/RefCountedObject.h>
#include <Poco/Runnable.h>
#include <Poco/StreamCopier.h>
#include <Poco/SynchronizedObject.h>
#include <Poco/Thread.h>
#include <Poco/URI.h>
#include <Poco/URIStreamOpener.h>
#include <Poco/Net/AcceptCertificateHandler.h>
#include <Poco/Net/Context.h>
#include <Poco/Net/DNS.h>
#include <Poco/Net/FTPClientSession.h>
#include <Poco/Net/HTTPClientSession.h>
#include <Poco/Net/HTTPCredentials.h>
#include <Poco/Net/HTTPMessage.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPSClientSession.h>
#include <Poco/Net/MessageHeader.h>
#include <Poco/Net/SSLManager.h>
#include <Poco/Net/WebSocket.h>
#include <scriptarray.h>
#include <scriptdictionary.h>
#include <entities.h>
#include "datastreams.h"
#include "internet.h"
#include "nvgt.h"
#include "nvgt_angelscript.h"
#include "pocostuff.h" // angelscript_refcounted
#include "version.h"

using namespace std;
using namespace Poco;
using namespace Poco::Net;

string html_entities_decode(const string& input) {
	vector<char> buffer(input.size() + 1, '\0');
	decode_html_entities_utf8(buffer.data(), input.c_str());
	return string(buffer.data());
}

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

template <class T, typename... A> void generic_construct(T* mem, A... args) { new (mem) T(args...); }
template <class T> void generic_copy_construct(T* mem, const T& other) { new (mem) T(other); }
template <class T> void generic_destruct(T* mem) { mem->~T(); }
template <class T> int opCmp(const T& first, const T& second) {
	if (first < second) return -1;
	else if (first > second) return 1;
	else return 0;
}
template <class T> int opCmpNoGT(const T& first, const T& second) {
	// Some classes have operator< and operator==, but not operator>.
	if (first < second) return -1;
	else if (first == second) return 0;
	else return 1;
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

// Wrappers for vector->scriptarray conversion.
CScriptArray* host_entry_get_aliases(const HostEntry& e) { return vector_to_scriptarray<string>(e.aliases(), "string"); }
CScriptArray* host_entry_get_addresses(const HostEntry& e) { return vector_to_scriptarray<IPAddress>(e.addresses(), "spec::ip_address"); }

// In NVGT we tend to overuse std::string, make sure sockets can handle this datatype. We should try to register versions of SendBytes and ReceiveBytes that works with a lower level datatype when possible especially because of the unnecessary memory usage incurred with std::string in this case.
template <class T> int socket_send_bytes(T& sock, const string& data, int flags) { return sock.sendBytes(data.data(), data.size(), flags); }
template <class T> string socket_receive_bytes(T& sock, int length, int flags) {
	if (!length) return 0;
	string result(length, 0); // ooouuuch this initialization to null chars hurts and is a waste, find a way to fix it!
	int recv_len = sock.receiveBytes(result.data(), length, flags);
	result.resize(recv_len);
	return result;
}
template <class T> string socket_receive_bytes_buf(T& sock, int flags, const Timespan& timeout) {
	Buffer<char> buf(0);
	sock.receiveBytes(buf, flags);
	return string(buf.begin(), buf.end());
}
int websocket_send_frame(WebSocket& sock, const string& data, int flags) { return sock.sendFrame(data.data(), data.size(), flags); }
string websocket_receive_frame(WebSocket& sock, int& flags) {
	Buffer<char> buf(0);
	int recv_len = sock.receiveFrame(buf, flags);
	if (recv_len == 0) return "";
	return string(buf.begin(), buf.end());
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
	engine->RegisterObjectMethod(type.c_str(), "const string& name_at(uint) const", asFUNCTION(name_value_collection_name_at<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "const string& value_at(uint) const", asFUNCTION(name_value_collection_value_at<T>), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectMethod(type.c_str(), "void set_keep_alive_timeout(const timespan&in timeout) property", asMETHOD(T, setKeepAliveTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "timespan get_keep_alive_timeout() const property", asMETHOD(T, getKeepAliveTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_send_timeout(const timespan&in timeout) property", asMETHOD(T, setSendTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "timespan get_send_timeout() const property", asMETHOD(T, getSendTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_receive_timeout(const timespan&in timeout) property", asMETHOD(T, setReceiveTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "timespan get_receive_timeout() const property", asMETHOD(T, getReceiveTimeout), asCALL_THISCALL);
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
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(uint16 active_data_port = 0)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, UInt16>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const string&in host, uint16 port = 21, const string&in username = \"\", const string&in password = \"\", uint16 active_data_port = 0)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const string&, UInt16, const string&, const string&, UInt16>)), asCALL_CDECL);
	engine->RegisterObjectMethod(type.c_str(), "void set_passive(bool passive, bool use_rfc1738 = true)", asMETHOD(T, setPassive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_passive() const property", asMETHOD(T, getPassive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void open(const string&in host, uint16 port, const string&in username = \"\", const string&in password = \"\")", asMETHOD(T, open), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void login(const string&in username, const string&in password)", asMETHOD(T, login), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void logout()", asMETHOD(T, logout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void close()", asMETHOD(T, close), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string system_type()", asMETHOD(T, systemType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_file_type(ftp_file_type type)", asMETHOD(T, setFileType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "ftp_file_type get_file_type() const property", asMETHOD(T, getFileType), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_working_directory(const string&in path)", asMETHOD(T, setWorkingDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "string get_working_directory()", asMETHOD(T, getWorkingDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void cdup()", asMETHOD(T, cdup), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void rename(const string&in source, const string&in destination)", asMETHOD(T, rename), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove(const string&in path)", asMETHOD(T, remove), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void create_directory(const string&in path)", asMETHOD(T, createDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void remove_directory(const string&in path)", asMETHOD(T, removeDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ begin_download(const string&in path, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(ftp_client_begin_download<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void end_download()", asMETHOD(T, endDownload), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ begin_upload(const string&in path, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(ftp_client_begin_upload<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void end_upload()", asMETHOD(T, endUpload), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "datastream@ begin_list(const string&in path = \"\", bool extended = false, const string&in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asFUNCTION(ftp_client_begin_list<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void end_list()", asMETHOD(T, endList), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void abort()", asMETHOD(T, abort), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int send_command(const string&in command, string& response)", asMETHODPR(T, sendCommand, (const string&, string&), int), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int send_command(const string&in command, const string&in argument, string& response)", asMETHODPR(T, sendCommand, (const string&, const string&, string&), int), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_open() const property", asMETHOD(T, isOpen), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_logged_in() const property", asMETHOD(T, isLoggedIn), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_secure() const property", asMETHOD(T, isSecure), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "const string& get_welcome_message() const property", asMETHOD(T, welcomeMessage), asCALL_THISCALL);
}
void RegisterHTTPCredentials(asIScriptEngine* engine) {
	angelscript_refcounted_register<HTTPCredentials>(engine, "http_credentials");
	engine->RegisterObjectBehaviour("http_credentials", asBEHAVE_FACTORY, "http_credentials@ f()", asFUNCTION((angelscript_refcounted_factory<HTTPCredentials>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("http_credentials", asBEHAVE_FACTORY, "http_credentials@ f(const string&in username, const string&in password)", asFUNCTION((angelscript_refcounted_factory<HTTPCredentials, const string&, const string&>)), asCALL_CDECL);
	engine->RegisterObjectMethod("http_credentials", "void from_user_info(const string&in user_info)", asMETHOD(HTTPCredentials, fromUserInfo), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void from_uri(const spec::uri&in uri)", asMETHOD(HTTPCredentials, fromURI), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void clear()", asMETHOD(HTTPCredentials, clear), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void set_username(const string&in username) property", asMETHOD(HTTPCredentials, setUsername), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "string get_username() const property", asMETHOD(HTTPCredentials, getUsername), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void set_password(const string&in password) property", asMETHOD(HTTPCredentials, setPassword), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "string get_password() const property", asMETHOD(HTTPCredentials, getPassword), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void set_host(const string&in host) property", asMETHOD(HTTPCredentials, setHost), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "string get_host() const property", asMETHOD(HTTPCredentials, getHost), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "bool get_empty() const property", asMETHOD(HTTPCredentials, empty), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void authenticate(http_request& request, const http_response&in response)", asMETHOD(HTTPCredentials, authenticate), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void update_auth_info(http_request& request)", asMETHOD(HTTPCredentials, updateAuthInfo), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void proxy_authenticate(http_request& request, const http_response&in response)", asMETHOD(HTTPCredentials, proxyAuthenticate), asCALL_THISCALL);
	engine->RegisterObjectMethod("http_credentials", "void update_proxy_auth_info(http_request& request)", asMETHOD(HTTPCredentials, updateProxyAuthInfo), asCALL_THISCALL);
	engine->RegisterGlobalFunction("bool http_credentials_is_basic(const string&in header)", asFUNCTION(HTTPCredentials::isBasicCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_digest(const string&in header)", asFUNCTION(HTTPCredentials::isDigestCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_ntlm(const string&in header)", asFUNCTION(HTTPCredentials::isNTLMCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_basic(const http_request&in request)", asFUNCTION(HTTPCredentials::hasBasicCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_digest(const http_request&in request)", asFUNCTION(HTTPCredentials::hasDigestCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_ntlm(const http_request&in request)", asFUNCTION(HTTPCredentials::hasNTLMCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_proxy_basic(const http_request&in request)", asFUNCTION(HTTPCredentials::hasProxyBasicCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_proxy_digest(const http_request&in request)", asFUNCTION(HTTPCredentials::hasProxyDigestCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_is_proxy_ntlm(const http_request&in request)", asFUNCTION(HTTPCredentials::hasProxyNTLMCredentials), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_extract(const string&in user_info, string&out username, string&out password)", asFUNCTIONPR(HTTPCredentials::extractCredentials, (const string&, string&, string&), void), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool http_credentials_extract(const spec::uri&in uri, string&out username, string&out password)", asFUNCTIONPR(HTTPCredentials::extractCredentials, (const URI&, string&, string&), void), asCALL_CDECL);
}
void RegisterIPAddress(asIScriptEngine* engine) {
	// Also registers SocketAddress as an aside.
	engine->SetDefaultNamespace("spec");
	engine->RegisterEnum("ip_address_family");
	engine->RegisterEnumValue("ip_address_family", "IP_FAMILY_UNKNOWN", AddressFamily::UNKNOWN);
	#ifdef POCO_HAS_UNIX_SOCKET
	engine->RegisterEnumValue("ip_address_family", "IP_FAMILY_unix_local", AddressFamily::UNIX_LOCAL);
	#else
	engine->RegisterEnumValue("ip_address_family", "IP_FAMILY_unix_local", AddressFamily::UNKNOWN);
	#endif
	engine->RegisterEnumValue("ip_address_family", "IP_FAMILY_IPV4", AddressFamily::IPv4);
	engine->RegisterEnumValue("ip_address_family", "IP_FAMILY_IPV6", AddressFamily::IPv6);
	engine->RegisterObjectType("ip_address", sizeof(IPAddress), asOBJ_VALUE | asGetTypeTraits<IPAddress>());
	engine->RegisterObjectBehaviour("ip_address", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(generic_construct<IPAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ip_address", asBEHAVE_CONSTRUCT, "void f(ip_address_family)", asFUNCTION((generic_construct<IPAddress, AddressFamily::Family>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ip_address", asBEHAVE_CONSTRUCT, "void f(const string&in addr)", asFUNCTION((generic_construct<IPAddress, const string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ip_address", asBEHAVE_CONSTRUCT, "void f(const string&in addr, ip_address_family)", asFUNCTION((generic_construct<IPAddress, const string&, AddressFamily::Family>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ip_address", asBEHAVE_CONSTRUCT, "void f(const ip_address&in)", asFUNCTION(generic_copy_construct<IPAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("ip_address", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(generic_destruct<IPAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("ip_address", "ip_address& opAssign(const ip_address&in addr)", asMETHODPR(IPAddress, operator=, (const IPAddress&), IPAddress&), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_v4() const property", asMETHOD(IPAddress, isV4), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_v6() const property", asMETHOD(IPAddress, isV6), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "ip_address_family get_family() const property", asMETHOD(IPAddress, family), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "uint get_scope() const property", asMETHOD(IPAddress, scope), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "string opImplConv() const", asMETHOD(IPAddress, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_wildcard() const property", asMETHOD(IPAddress, isWildcard), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_broadcast() const property", asMETHOD(IPAddress, isBroadcast), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_loopback() const property", asMETHOD(IPAddress, isLoopback), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_multicast() const property", asMETHOD(IPAddress, isMulticast), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_unicast() const property", asMETHOD(IPAddress, isUnicast), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_link_local() const property", asMETHOD(IPAddress, isLinkLocal), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_site_local() const property", asMETHOD(IPAddress, isSiteLocal), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_IPV4_compatible() const property", asMETHOD(IPAddress, isIPv4Compatible), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_IPV4_mapped() const property", asMETHOD(IPAddress, isIPv4Mapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_well_known_multicast() const property", asMETHOD(IPAddress, isWellKnownMC), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_node_local_multicast() const property", asMETHOD(IPAddress, isNodeLocalMC), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_link_local_multicast() const property", asMETHOD(IPAddress, isLinkLocalMC), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_site_local_multicast() const property", asMETHOD(IPAddress, isSiteLocalMC), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_org_local_multicast() const property", asMETHOD(IPAddress, isOrgLocalMC), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool get_is_global_multicast() const property", asMETHOD(IPAddress, isGlobalMC), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "bool opEquals(const ip_address&in addr) const", asMETHOD(IPAddress, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "int opCmp(const ip_address&in)", asFUNCTION(opCmp<IPAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("ip_address", "ip_address opAnd(const ip_address&in addr) const", asMETHOD(IPAddress, operator&), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "ip_address opOr(const ip_address&in addr) const", asMETHOD(IPAddress, operator|), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "ip_address opXor(const ip_address&in addr) const", asMETHOD(IPAddress, operator^), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "ip_address opCom() const", asMETHOD(IPAddress, operator~), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "uint get_prefix_length() const property", asMETHOD(IPAddress, prefixLength), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "void mask(const ip_address&in mask)", asMETHODPR(IPAddress, mask, (const IPAddress&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("ip_address", "void mask(const ip_address&in mask, const ip_address&in set)", asMETHODPR(IPAddress, mask, (const IPAddress&, const IPAddress&), void), asCALL_THISCALL);
	engine->RegisterGlobalFunction("bool parse_ip_address(const string&in addr_in, ip_address&out addr_out)", asFUNCTION(IPAddress::tryParse), asCALL_CDECL);
	engine->RegisterGlobalFunction("ip_address wildcard_ip_address(spec::ip_address_family)", asFUNCTION(IPAddress::wildcard), asCALL_CDECL);
	engine->RegisterGlobalFunction("ip_address broadcast_ip_address()", asFUNCTION(IPAddress::broadcast), asCALL_CDECL);
	engine->SetDefaultNamespace("");
	engine->RegisterObjectType("socket_address", sizeof(SocketAddress), asOBJ_VALUE | asGetTypeTraits<SocketAddress>());
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(generic_construct<SocketAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(spec::ip_address_family) explicit", asFUNCTION((generic_construct<SocketAddress, AddressFamily::Family>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(uint16 port) explicit", asFUNCTION((generic_construct<SocketAddress, UInt16>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(const spec::ip_address&in addr, uint16 port)", asFUNCTION((generic_construct<SocketAddress, const IPAddress&, UInt16>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(const string&in host_and_port)", asFUNCTION((generic_construct<SocketAddress, const string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(const string&in host, uint16 port)", asFUNCTION((generic_construct<SocketAddress, const string&, UInt16>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(spec::ip_address_family, uint16 port)", asFUNCTION((generic_construct<SocketAddress, AddressFamily::Family, UInt16>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(spec::ip_address_family, const string&in addr)", asFUNCTION((generic_construct<SocketAddress, AddressFamily::Family, const string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(spec::ip_address_family, const string&in host, uint16 port)", asFUNCTION((generic_construct<SocketAddress, AddressFamily::Family, const string&, UInt16>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(spec::ip_address_family, const string&in host, const string&in port)", asFUNCTION((generic_construct<SocketAddress, AddressFamily::Family, const string&, const string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_CONSTRUCT, "void f(const socket_address&in)", asFUNCTION(generic_copy_construct<SocketAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("socket_address", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(generic_destruct<SocketAddress>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("socket_address", "socket_address& opAssign(const socket_address&in addr)", asMETHODPR(SocketAddress, operator=, (const SocketAddress&), SocketAddress&), asCALL_THISCALL);
	engine->RegisterObjectMethod("socket_address", "spec::ip_address get_host() const property", asMETHOD(SocketAddress, host), asCALL_THISCALL);
	engine->RegisterObjectMethod("socket_address", "uint16 get_port() const property", asMETHOD(SocketAddress, port), asCALL_THISCALL);
	engine->RegisterObjectMethod("socket_address", "string opImplConv() const", asMETHOD(SocketAddress, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("socket_address", "spec::ip_address_family get_family() const property", asMETHOD(SocketAddress, family), asCALL_THISCALL);
	engine->RegisterObjectMethod("socket_address", "int opCmp(const socket_address&in)", asFUNCTION(opCmpNoGT<SocketAddress>), asCALL_CDECL_OBJFIRST);
}
template <class T> void RegisterSocket(asIScriptEngine* engine, const std::string& type) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	if constexpr(!std::is_same_v<T, WebSocket>) engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f()", type).c_str(), asFUNCTION(angelscript_refcounted_factory<T>), asCALL_CDECL);
	if (type != "socket") 	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const socket&in sock)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const Socket&>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const %s&in sock)", type, type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const T&>)), asCALL_CDECL);
	if (type != "socket") 	engine->RegisterObjectMethod(type.c_str(), format("%s& opAssign(const socket&in sock)", type).c_str(), asMETHODPR(T, operator=, (const Socket&), T&), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), format("%s& opAssign(const %s&in socket)", type, type).c_str(), asMETHODPR(T, operator=, (const T&), T&), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), format("int opCmp(const %s&in)", type).c_str(), asFUNCTION(opCmp<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), format("socket_type get_type() const property", type).c_str(), asMETHOD(T, type), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_null() const property", asMETHOD(T, isNull), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_stream() const property", asMETHOD(T, isStream), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_datagram() const property", asMETHOD(T, isDatagram), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_is_raw() const property", asMETHOD(T, isRaw), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void close()", asMETHOD(T, close), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool poll(const timespan& timeout, int mode) const", asMETHOD(T, poll), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_available() const property", asMETHOD(T, available), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_error() const property", asMETHOD(T, getError), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_send_buffer_size(int size) property", asMETHOD(T, setSendBufferSize), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_send_buffer_size() const property", asMETHOD(T, getSendBufferSize), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_receive_buffer_size(int size) property", asMETHOD(T, setReceiveBufferSize), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int get_receive_buffer_size() const property", asMETHOD(T, getReceiveBufferSize), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_send_timeout(const timespan&in timeout) property", asMETHOD(T, setSendTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "timespan get_send_timeout() const property", asMETHOD(T, getSendTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_receive_timeout(const timespan&in timeout) property", asMETHOD(T, setReceiveTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "timespan get_receive_timeout() const property", asMETHOD(T, getReceiveTimeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_option(int level, int option, int value)", asMETHODPR(T, setOption, (int, int, int), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_option(int level, int option, uint value)", asMETHODPR(T, setOption, (int, int, unsigned), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_option(int level, int option, uint8 value)", asMETHODPR(T, setOption, (int, int, unsigned char), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_option(int level, int option, const timespan&in value)", asMETHODPR(T, setOption, (int, int, const Timespan&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_option(int level, int option, const spec::ip_address&in value)", asMETHODPR(T, setOption, (int, int, const IPAddress&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_option(int level, int option, int&out value) const", asMETHODPR(T, getOption, (int, int, int&) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_option(int level, int option, uint&out value) const", asMETHODPR(T, getOption, (int, int, unsigned&) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_option(int level, int option, uint8&out value) const", asMETHODPR(T, getOption, (int, int, unsigned char&) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_option(int level, int option, timespan&out value) const", asMETHODPR(T, getOption, (int, int, Timespan&) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_option(int level, int option, spec::ip_address&out value)", asMETHODPR(T, getOption, (int, int, IPAddress&) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_linger(bool on, int seconds)", asMETHOD(T, setLinger), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void get_linger(bool&out on, int&out seconds)", asMETHOD(T, getLinger), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_no_delay(bool flag) property", asMETHOD(T, setNoDelay), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_no_delay() const property", asMETHOD(T, getNoDelay), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_keep_alive(bool flag) property", asMETHOD(T, setKeepAlive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_keep_alive() const property", asMETHOD(T, getKeepAlive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_reuse_address(bool flag) property", asMETHOD(T, setReuseAddress), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_reuse_address() const property", asMETHOD(T, getReuseAddress), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_reuse_port(bool flag) property", asMETHOD(T, setReusePort), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_reuse_port() const property", asMETHOD(T, getReusePort), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_oob_inline(bool flag) property", asMETHOD(T, setOOBInline), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_oob_inline() const property", asMETHOD(T, getOOBInline), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void set_blocking(bool flag) property", asMETHOD(T, setBlocking), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_blocking() const property", asMETHOD(T, getBlocking), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "socket_address get_address() const property", asMETHOD(T, address), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "socket_address get_peer_address() const property", asMETHOD(T, peerAddress), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "bool get_secure() const property", asMETHOD(T, secure), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void init(int af)", asMETHOD(T, init), asCALL_THISCALL);
}
template <class T> void RegisterStreamSocket(asIScriptEngine* engine, const std::string& type) {
	RegisterSocket<T>(engine, type);
	if constexpr(!std::is_same_v<T, WebSocket>) {
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const socket_address&in address)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const SocketAddress&>)), asCALL_CDECL);
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ f(const spec::ip_address_family)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, SocketAddress::Family>)), asCALL_CDECL);
		engine->RegisterObjectMethod(type.c_str(), "void connect(const socket_address&in address)", asMETHODPR(T, connect, (const SocketAddress&), void), asCALL_THISCALL);
		engine->RegisterObjectMethod(type.c_str(), "void connect(const socket_address&in address, const timespan&in timeout)", asMETHODPR(T, connect, (const SocketAddress&, const Timespan&), void), asCALL_THISCALL);
		engine->RegisterObjectMethod(type.c_str(), "void connect_nonblocking(const socket_address&in address)", asMETHOD(T, connectNB), asCALL_THISCALL);
		engine->RegisterObjectMethod(type.c_str(), "bool bind(const socket_address&in address, bool reuse_address = false, bool IPv6_only = false)", asMETHOD(T, bind), asCALL_THISCALL);
	}
	engine->RegisterObjectMethod(type.c_str(), "void shutdown_receive()", asMETHOD(T, shutdownReceive), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void shutdown_send()", asMETHOD(T, shutdownSend), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "void shutdown()", asMETHOD(T, shutdown), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), "int send_bytes(const string&in data, int flags = 0)", asFUNCTION(socket_send_bytes<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "string receive_bytes(int length, int flags = 0)", asFUNCTION(socket_receive_bytes<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "string receive_bytes(int flags = 0, const timespan& timeout = 100000)", asFUNCTION(socket_receive_bytes_buf<T>), asCALL_CDECL_OBJFIRST);
}
void RegisterWebSocket(asIScriptEngine* engine) {
	engine->RegisterEnum("web_socket_mode");
	engine->RegisterEnumValue("web_socket_mode", "WS_SERVER", WebSocket::WS_SERVER);
	engine->RegisterEnumValue("web_socket_mode", "WS_CLIENT", WebSocket::WS_CLIENT);
	engine->RegisterEnum("web_socket_frame_flags");
	engine->RegisterEnumValue("web_socket_frame_flags", "WS_FRAME_FLAG_FIN", WebSocket::FRAME_FLAG_FIN);
	engine->RegisterEnum("web_socket_frame_opcodes");
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_CONT", WebSocket::FRAME_OP_CONT);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_TEXT", WebSocket::FRAME_OP_TEXT);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_BINARY", WebSocket::FRAME_OP_BINARY);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_CLOSE", WebSocket::FRAME_OP_CLOSE);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_PING", WebSocket::FRAME_OP_PING);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_PONG", WebSocket::FRAME_OP_PONG);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_BITMASK", WebSocket::FRAME_OP_BITMASK);
	engine->RegisterEnumValue("web_socket_frame_opcodes", "WS_FRAME_OP_SETRAW", WebSocket::FRAME_OP_SETRAW);
	engine->RegisterEnum("web_socket_send_flags");
	engine->RegisterEnumValue("web_socket_send_flags", "WS_FRAME_TEXT", WebSocket::FRAME_TEXT);
	engine->RegisterEnumValue("web_socket_send_flags", "WS_FRAME_BINARY", WebSocket::FRAME_BINARY);
	engine->RegisterEnum("web_socket_status_codes");
	engine->RegisterEnumValue("web_socket_status_codes", "WS_NORMAL_CLOSE", WebSocket::WS_NORMAL_CLOSE);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_ENDPOINT_GOING_AWAY", WebSocket::WS_ENDPOINT_GOING_AWAY);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_PROTOCOL_ERROR", WebSocket::WS_PROTOCOL_ERROR);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_PAYLOAD_NOT_ACCEPTABLE", WebSocket::WS_PAYLOAD_NOT_ACCEPTABLE);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_RESERVED", WebSocket::WS_RESERVED);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_RESERVED_NO_STATUS_CODE", WebSocket::WS_RESERVED_NO_STATUS_CODE);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_RESERVED_ABNORMAL_CLOSE", WebSocket::WS_RESERVED_ABNORMAL_CLOSE);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_MALFORMED_PAYLOAD", WebSocket::WS_MALFORMED_PAYLOAD);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_POLICY_VIOLATION", WebSocket::WS_POLICY_VIOLATION);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_PAYLOAD_TOO_BIG", WebSocket::WS_PAYLOAD_TOO_BIG);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_EXTENSION_REQUIRED", WebSocket::WS_EXTENSION_REQUIRED);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_UNEXPECTED_CONDITION", WebSocket::WS_UNEXPECTED_CONDITION);
	engine->RegisterEnumValue("web_socket_status_codes", "WS_RESERVED_TLS_FAILURE", WebSocket::WS_RESERVED_TLS_FAILURE);
	engine->RegisterEnum("web_socket_error_codes");
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_NO_HANDSHAKE", WebSocket::WS_ERR_NO_HANDSHAKE);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_HANDSHAKE_NO_VERSION", WebSocket::WS_ERR_HANDSHAKE_NO_VERSION);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_HANDSHAKE_UNSUPPORTED_VERSION", WebSocket::WS_ERR_HANDSHAKE_UNSUPPORTED_VERSION);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_HANDSHAKE_NO_KEY", WebSocket::WS_ERR_HANDSHAKE_NO_KEY);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_HANDSHAKE_ACCEPT", WebSocket::WS_ERR_HANDSHAKE_ACCEPT);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_UNAUTHORIZED", WebSocket::WS_ERR_UNAUTHORIZED);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_PAYLOAD_TOO_BIG", WebSocket::WS_ERR_PAYLOAD_TOO_BIG);
	engine->RegisterEnumValue("web_socket_error_codes", "WS_ERR_INCOMPLETE_FRAME", WebSocket::WS_ERR_INCOMPLETE_FRAME);
	RegisterStreamSocket<WebSocket>(engine, "web_socket");
	engine->RegisterObjectBehaviour("web_socket", asBEHAVE_FACTORY, "web_socket@ s(http_client& cs, http_request& request, http_response& response)", asFUNCTION((angelscript_refcounted_factory<WebSocket, HTTPClientSession&, HTTPRequest&, HTTPResponse&>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("web_socket", asBEHAVE_FACTORY, "web_socket@ s(http_client& cs, http_request& request, http_response& response, http_credentials& credentials)", asFUNCTION((angelscript_refcounted_factory<WebSocket, HTTPClientSession&, HTTPRequest&, HTTPResponse&, HTTPCredentials&>)), asCALL_CDECL);
	engine->RegisterObjectMethod("web_socket", "void shutdown(uint16 status_code, const string&in status_message = \"\")", asMETHODPR(WebSocket, shutdown, (UInt16, const string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("web_socket", "int send_frame(const string&in data, int flags = WS_FRAME_TEXT)", asFUNCTION(websocket_send_frame), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("web_socket", "string receive_frame(int&out flags)", asFUNCTION(websocket_receive_frame), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("web_socket", "web_socket_mode get_mode() const property", asMETHOD(WebSocket, mode), asCALL_THISCALL);
	engine->RegisterObjectMethod("web_socket", "void set_max_payload_size(int size) property", asMETHOD(WebSocket, setMaxPayloadSize), asCALL_THISCALL);
	engine->RegisterObjectMethod("web_socket", "int get_max_payload_size() const property", asMETHOD(WebSocket, getMaxPayloadSize), asCALL_THISCALL);
}
void RegisterDNS(asIScriptEngine* engine) {
	engine->RegisterObjectType("dns_host_entry", sizeof(HostEntry), asOBJ_VALUE | asGetTypeTraits<HostEntry>());
	engine->RegisterObjectBehaviour("dns_host_entry", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(generic_construct<HostEntry>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("dns_host_entry", asBEHAVE_CONSTRUCT, "void f(const dns_host_entry&in)", asFUNCTION(generic_copy_construct<HostEntry>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("dns_host_entry", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(generic_destruct<HostEntry>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("dns_host_entry", "dns_host_entry& opAssign(const dns_host_entry&in e)", asMETHOD(HostEntry, operator=), asCALL_THISCALL);
	engine->RegisterObjectMethod("dns_host_entry", "const string& get_name() const property", asMETHOD(HostEntry, name), asCALL_THISCALL);
	engine->RegisterObjectMethod("dns_host_entry", "string[]@ get_aliases() const", asFUNCTION(host_entry_get_aliases), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("dns_host_entry", "spec::ip_address[]@ get_addresses() const", asFUNCTION(host_entry_get_addresses), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("dns_host_entry dns_resolve(const string&in address)", asFUNCTION(DNS::resolve), asCALL_CDECL);
	engine->RegisterGlobalFunction("spec::ip_address dns_resolve_single(const string&in address)", asFUNCTION(DNS::resolveOne), asCALL_CDECL);
	engine->RegisterGlobalFunction("dns_host_entry system_dns_host_entry()", asFUNCTION(DNS::thisHost), asCALL_CDECL);
}

// NVGT's mid-level HTTP. This wraps the various Poco HTTP classes into a convenient asynchronous interface.
class http : public RefCountedObject, Runnable, public SynchronizedObject {
	HTTPClientSession* _session;
	HTTPRequest _request;
	HTTPResponse _response;
	HTTPCredentials _creds;
	string _request_body, _response_body, _user_agent;
	Thread worker;
	URI _url;
	streamsize _bytes_downloaded;
	atomic<int> _max_retries, _retry_delay;
public:
	http() : _session(nullptr), _bytes_downloaded(0), _max_retries(10), _retry_delay(0) { set_user_agent(); }
	bool request(const string& method, const URI& url, const NameValueCollection* headers, const string& body, const HTTPCredentials* creds = nullptr) {
		if (worker.isRunning()) return false;
		if (url.getScheme() != "http" && url.getScheme() != "https") return false;
		ScopedLock lock(*this);
		reset();
		_request.setMethod(method);
		_request.setContentLength(body.length());
		_url = url;
		if (creds) {
			_creds.setHost(creds->getHost());
			_creds.setUsername(creds->getUsername());
			_creds.setPassword(creds->getPassword());
		}
		if (!url.getUserInfo().empty()) _creds.fromURI(url);
		_request_body = body;
		if (headers) {
			for (const auto& header : *headers) _request.add(header.first, header.second);
		}
		worker.start(*this);
		return true;
	}
	~http() { reset(); }
	void reset() {
		if (worker.isRunning()) {
			notify();
			worker.join();
		}
		_request_body = _response_body = "";
		_creds.clear();
		_request = HTTPRequest(HTTPMessage::HTTP_1_1);
		_request.setContentLength(0);
		_request.set("User-Agent", "nvgt " + NVGT_VERSION);
		_response.clear();
		_max_retries = 10;
		_bytes_downloaded = _retry_delay = 0;
		tryWait(0); // Try making sure the event is not signaled.
	}
	bool get(const URI& url, const NameValueCollection* headers, const HTTPCredentials* creds = nullptr) { return request(HTTPRequest::HTTP_GET, url, headers, "", creds); }
	bool head(const URI& url, const NameValueCollection* headers, const HTTPCredentials* creds = nullptr) { return request(HTTPRequest::HTTP_HEAD, url, headers, "", creds); }
	bool post(const URI& url, const string& body, const NameValueCollection* headers = nullptr, const HTTPCredentials* creds = nullptr) { return request(HTTPRequest::HTTP_POST, url, headers, body, creds); }
	void run() {
		bool authorize = false;
		int tries = _max_retries;
		while (tries && !tryWait(_retry_delay)) {
			tries--;
			try {
				string path = _url.getPathAndQuery();
				if (path.empty()) path = "/";
				lock();
				HTTPRequest req(_request);
				req.setHost(_url.getHost());
				req.setURI(path);
				unlock();
				if (req.getContentType() == HTTPMessage::UNKNOWN_CONTENT_TYPE) req.setContentType("application/x-www-form-urlencoded");
				lock();
				HTTPResponse tmp_response = _response;
				if (!_session) _session = _url.getScheme() == "http"? new HTTPClientSession(_url.getHost(), _url.getPort()) : new HTTPSClientSession(_url.getHost(), _url.getPort());
				if (authorize) _creds.authenticate(req, tmp_response);
				std::ostream& ostr = _session->sendRequest(req);
				unlock();;
				if (tryWait(0)) break;
				ostr << _request_body;
				std::istream& istr = _session->receiveResponse(tmp_response);
				lock();
				_response = tmp_response;
				bool moved = (_response.getStatus() == HTTPResponse::HTTP_MOVED_PERMANENTLY || _response.getStatus() == HTTPResponse::HTTP_FOUND || _response.getStatus() == HTTPResponse::HTTP_SEE_OTHER || _response.getStatus() == HTTPResponse::HTTP_TEMPORARY_REDIRECT);
				if (moved) {
					_url.resolve(_response.get("Location"));
					authorize = false;
					delete _session;
					_session = nullptr;
					unlock();
					continue;
				} else if (_response.getStatus() == HTTPResponse::HTTP_UNAUTHORIZED && !authorize && !_creds.empty()) {
					unlock();
					authorize = true;
					NullOutputStream null;
					StreamCopier::copyStream(istr, null);
					continue;
				}
				unlock();
				string buffer(512, '\0');
				while (istr.good() && !tryWait(0)) {
					istr.read(buffer.data(), 512);
					streamsize count = istr.gcount();
					ScopedLock lock(*this);
					_response_body.append(buffer.begin(), buffer.begin() + count);
					_bytes_downloaded += count;
				}
				break;
			} catch(Exception& e) {
				if (_session) delete _session;
				_session = nullptr;
				unlock();
				return;
			}
		}
		if (_session) {
			_session->reset();
			delete _session;
		}
		_session = nullptr;
		return;
	}
	HTTPResponse* get_response_headers() {
		ScopedLock lock(*this);
		return angelscript_refcounted_factory<HTTPResponse, const HTTPResponse&>(_response);
	}
	string operator[](const string& key) {
		ScopedLock lock(*this);
		return _response[key];
	}
	string get_response_body() {
		ScopedLock lock(*this);
		string r = _response_body;
		_response_body.clear();
		return r;
	}
	int get_status_code() {
		ScopedLock lock(*this);
		if (_response.empty()) return 0;
		return _response.getStatus();
	}
	float get_progress() {
		ScopedLock lock(*this);
		if (_response.empty()) return 0;
		else if (!_response.hasContentLength()) return -1;
		return float(_bytes_downloaded) / _response.getContentLength();
	}
	URI get_url() {
		ScopedLock lock(*this);
		return _url;
	}
	string get_user_agent() const { return _user_agent; }
	void set_user_agent(const string& agent = "") {
		if (agent.empty()) _user_agent = "nvgt " + NVGT_VERSION;
		else _user_agent = agent;
	}
	int get_max_retries() const { return _max_retries; }
	void set_max_retries(int retries) { _max_retries = retries; }
	int get_retry_delay() const { return _retry_delay; }
	void set_retry_delay(int delay = 0) { _retry_delay = delay; }
	void wait() {
		if (!worker.isRunning()) return;
		return worker.join();
	}
	bool is_complete() {
		return !worker.isRunning() || worker.tryJoin(0);
	}
	bool is_running() const {
		return worker.isRunning();
	}
};
http* http_factory() { return new http(); }
void RegisterHTTP(asIScriptEngine* engine) {
	engine->RegisterObjectType("http", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("http", asBEHAVE_FACTORY, "http@ f()", asFUNCTION(http_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("http", asBEHAVE_ADDREF, "void f()", asMETHODPR(http, duplicate, () const, void), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("http", asBEHAVE_RELEASE, "void f()", asMETHODPR(http, release, () const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "bool get(const spec::uri&in url, const name_value_collection@+ headers = null, const http_credentials@+ creds = null)", asMETHOD(http, get), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "bool head(const spec::uri&in url, const name_value_collection@+ headers = null, const http_credentials@+ creds = null)", asMETHOD(http, head), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "bool post(const spec::uri&in url, const string&in body, const name_value_collection@+ headers = null, const http_credentials@+ creds = null)", asMETHOD(http, post), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "http_response@ get_response_headers() property", asMETHOD(http, get_response_headers), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "string get_response_body() property", asMETHOD(http, get_response_body), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "string request()", asMETHOD(http, get_response_body), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "string opIndex(const string&in key)", asMETHOD(http, operator[]), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "spec::uri get_url() property", asMETHOD(http, get_url), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "float get_progress() property", asMETHOD(http, get_progress), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "int get_status_code() property", asMETHOD(http, get_status_code), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "string get_user_agent() const property", asMETHOD(http, get_user_agent), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "void set_user_agent(const string&in agent = \"\") property", asMETHOD(http, set_user_agent), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "int get_max_retries() const property", asMETHOD(http, get_max_retries), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "void set_max_retries(int retries) property", asMETHOD(http, set_max_retries), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "int get_retry_delay() const property", asMETHOD(http, get_retry_delay), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "void set_retry_delay(int delay = 0) property", asMETHOD(http, set_retry_delay), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "bool get_complete() property", asMETHOD(http, is_complete), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "bool get_running() property", asMETHOD(http, is_running), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "void wait()", asMETHOD(http, wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("http", "void reset()", asMETHOD(http, reset), asCALL_THISCALL);
}

// NVGT's highest level HTTP.
string url_request(const string& method, const string& url, const string& data, HTTPResponse* resp) {
	http h;
	if (!h.request(method, URI(url), nullptr, data)) return "";
	h.wait();
	if (resp) *resp = *h.get_response_headers();
	return h.get_response_body();
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
	engine->RegisterEnum("socket_type");
	engine->RegisterEnumValue("socket_type", "SOCKET_TYPE_STREAM", Socket::Type::SOCKET_TYPE_STREAM);
	engine->RegisterEnumValue("socket_type", "SOCKET_TYPE_DATAGRAM", Socket::Type::SOCKET_TYPE_DATAGRAM);
	engine->RegisterEnumValue("socket_type", "SOCKET_TYPE_RAW", Socket::Type::SOCKET_TYPE_RAW);
	engine->RegisterEnum("socket_select_mode");
	engine->RegisterEnumValue("socket_select_mode", "SOCKET_SELECT_READ", Socket::SELECT_READ);
	engine->RegisterEnumValue("socket_select_mode", "SOCKET_SELECT_WRITE", Socket::SELECT_WRITE);
	engine->RegisterEnumValue("socket_select_mode", "SOCKET_SELECT_ERROR", Socket::SELECT_ERROR);
	engine->RegisterGlobalFunction(_O("string html_entities_decode(const string&in input)"), asFUNCTION(html_entities_decode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string url_encode(const string&in url, const string&in reserved = \"\")"), asFUNCTION(url_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string url_decode(const string&in url, bool plus_as_space = true)"), asFUNCTION(url_decode), asCALL_CDECL);
	RegisterNameValueCollection<NameValueCollection>(engine, "name_value_collection");
	RegisterMessageHeader<MessageHeader, NameValueCollection>(engine, "internet_message_header", "name_value_collection");
	RegisterHTTPRequest<HTTPRequest, MessageHeader>(engine, "http_request", "internet_message_header");
	RegisterHTTPResponse<HTTPResponse, MessageHeader>(engine, "http_response", "internet_message_header");
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_NET);
	RegisterHTTPClientSession<HTTPClientSession>(engine, "http_client");
	RegisterHTTPClientSession<HTTPSClientSession>(engine, "https_client");
	engine->RegisterObjectMethod("http_client", "https_client@ opCast()", asFUNCTION((angelscript_refcounted_refcast<HTTPClientSession, HTTPSClientSession>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("https_client", "http_client@ opImplCast()", asFUNCTION((angelscript_refcounted_refcast<HTTPSClientSession, HTTPClientSession>)), asCALL_CDECL_OBJFIRST);
	RegisterHTTPCredentials(engine);
	RegisterIPAddress(engine);
	RegisterFTPClientSession<FTPClientSession>(engine, "ftp_client");
	RegisterSocket<Socket>(engine, "socket");
	RegisterStreamSocket<StreamSocket>(engine, "stream_socket");
	RegisterWebSocket(engine);
	RegisterDNS(engine);
	RegisterHTTP(engine);
	engine->RegisterGlobalFunction("string url_request(const string&in method, const string&in url, const string&in data = \"\", http_response&out response = void)", asFUNCTION(url_request), asCALL_CDECL);
	engine->RegisterGlobalFunction("string url_get(const string&in url, http_response&out response = void)", asFUNCTION(url_get), asCALL_CDECL);
	engine->RegisterGlobalFunction("string url_post(const string&in url, const string&in data, http_response&out response = void)", asFUNCTION(url_post), asCALL_CDECL);
}
