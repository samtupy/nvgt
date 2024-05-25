/* internet.cpp - libcurl wrapper plugin code
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

#include <sstream>
#include <cstring>
#include "internet.h"
#ifndef NVGT_PLUGIN_STATIC
	#define THREAD_IMPLEMENTATION
#endif
#include <thread.h>

std::string url_encode(const std::string& url) {
	std::stringstream r;
	for (int i = 0; i < url.size(); i++) {
		if (isalnum((unsigned char)url[i]) || url[i] == '-' || url[i] == '.' || url[i] == '_' || url[i] == '~')
			r << url[i];
		else if (url[i] == ' ')
			r << "+";
		else {
			char tmp[4];
			snprintf(tmp, 4, "%%%02X", url[i]);
			r << tmp;
		}
	}
	return r.str();
}
std::string url_decode(const std::string& url) {
	std::stringstream r;
	for (int i = 0; i < url.size(); i++) {
		if (url[i] == '+') r << " ";
		else if (url[i] == '%' && i < url.size() - 2) {
			char ch = strtol(url.substr(i + 1, 2).c_str(), NULL, 16);
			r << ch;
			i += 2;
		} else r << url[i];
	}
	return r.str();
}


int internet_request_curl_debug(CURL* handle, curl_infotype type, char* data, size_t size, std::string* filename) {
	FILE* f = fopen(filename->c_str(), "ab");
	fwrite(data, 1, size, f);
	fputs("\r\n", f);
	fclose(f);
	return 0;
}
size_t internet_request_curl_progress(internet_request* req, curl_off_t dltotal, curl_off_t dlnow, curl_off_t ultotal, curl_off_t ulnow) {
	if (dlnow == 0x150 || dltotal == 0x150) return 0;
	req->bytes_downloaded = (double)dlnow;
	req->download_size = (double)dltotal;
	req->download_percent = (req->bytes_downloaded / req->download_size) * 100.0;
	req->bytes_uploaded = (double)ulnow;
	req->upload_size = (double)ultotal;
	req->download_percent = (req->bytes_downloaded / req->download_size) * 100.0;
	return req->abort_request ? 1 : 0;
}
size_t internet_request_curl_write(void* ptr, size_t size, size_t nmemb, std::string* data) {
	data->append((char*) ptr, size * nmemb);
	return size * nmemb;
}
size_t internet_request_curl_fwrite(void* ptr, size_t size, size_t nmemb, internet_request* req) {
	if (!req)
		return 0;
	if (!req->download_stream) {
		if (req->path == "") {
			req->response_body.append((char*) ptr, size * nmemb);
			return size * nmemb;
		}
		req->download_stream = fopen(req->path.c_str(), "wb");
		if (!req->download_stream)
			return 0;
	}
	size_t res = fwrite(ptr, size, nmemb, req->download_stream);
	fflush(req->download_stream);
	return res;
}
size_t internet_request_curl_read(void* ptr, size_t isize, size_t nmemb, internet_request* req) {
	if (!req)
		return 0;
	size_t size = isize * nmemb;
	if (req->payload_cursor + size >= req->payload.size())
		size = req->payload.size() - req->payload_cursor;
	memcpy(ptr, &(req->payload[req->payload_cursor]), size);
	req->payload_cursor += size;
	return size;
}
int internet_request_thread(void* raw_request) {
	if (!raw_request)
		return 0;
	internet_request* request = (internet_request*)raw_request;
	CURL* curl = curl_easy_init();
	if (curl) {
		request->no_curl = false;
		request->complete = false;
		request->in_progress = true;
		curl_slist* headers = NULL;
		if (request->mail_to == "")
			curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
		if (request->debug_file != "") {
			curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
			curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, internet_request_curl_debug);
			curl_easy_setopt(curl, CURLOPT_DEBUGDATA, &request->debug_file);
		}
		curl_easy_setopt(curl, CURLOPT_URL, request->url.c_str());
		bool ftp = request->url.substr(0, 6) == "ftp://" || request->url.substr(0, 7) == "ftps://";
		if (request->auth_username != "")
			curl_easy_setopt(curl, CURLOPT_USERNAME, request->auth_username.c_str());
		if (request->auth_password != "")
			curl_easy_setopt(curl, CURLOPT_PASSWORD, request->auth_password.c_str());
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L);
		if (!ftp) {
			curl_easy_setopt(curl, CURLOPT_USERAGENT, request->user_agent.c_str());
			curl_easy_setopt(curl, CURLOPT_MAXREDIRS, request->max_redirects);
			if (request->follow_redirects)
				curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
			else
				curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 0L);
			curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "");
		}
		curl_easy_setopt(curl, CURLOPT_TCP_KEEPALIVE, 1L);
		if (request->path == "") {
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, internet_request_curl_write);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &request->response_body);
		} else {
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, internet_request_curl_fwrite);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, request);
		}
		curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, internet_request_curl_write);
		curl_easy_setopt(curl, CURLOPT_HEADERDATA, &request->response_headers);
		curl_easy_setopt(curl, CURLOPT_XFERINFOFUNCTION, internet_request_curl_progress);
		curl_easy_setopt(curl, CURLOPT_XFERINFODATA, request);
		long proto;
		curl_easy_getinfo(curl, CURLINFO_PROTOCOL, &proto);
		curl_slist* mail_rcpt = NULL;
		if (request->payload != "") {
			if (request->mail_from == "" && request->mail_to == "" && !ftp) {
				curl_easy_setopt(curl, CURLOPT_POST, 1L);
				curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)request->payload.size());
				headers = curl_slist_append(headers, "Expect:");
			}
			if (request->mail_from != "")
				curl_easy_setopt(curl, CURLOPT_MAIL_FROM, request->mail_from.c_str());
			if (request->mail_to != "") {
				mail_rcpt = curl_slist_append(mail_rcpt, request->mail_to.c_str());
				curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, mail_rcpt);
				curl_easy_setopt(curl, CURLOPT_UPLOAD, 1);
				curl_easy_setopt(curl, CURLOPT_USE_SSL, CURLUSESSL_ALL);
			}
			curl_easy_setopt(curl, CURLOPT_READFUNCTION, internet_request_curl_read);
			curl_easy_setopt(curl, CURLOPT_READDATA, request);
			if (ftp) {
				curl_easy_setopt(curl, CURLOPT_UPLOAD, 1);
				curl_easy_setopt(curl, CURLOPT_INFILESIZE, request->payload.size());
			}
		}
		for (auto h : request->headers) {
			std::string header = h.first;
			header += ": ";
			header += h.second;
			headers = curl_slist_append(headers, header.c_str());
		}
		if (request->mail_to == "" && !ftp)
			curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
		else if (ftp && request->url.substr(request->url.size() - 1, 1) == "/")
			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "MLSD");
		char* url;
		curl_easy_perform(curl);
		curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &request->status_code);
		curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &request->total_time);
		curl_easy_getinfo(curl, CURLINFO_EFFECTIVE_URL, &url);
		if (url)
			request->final_url = url;
		curl_slist_free_all(headers);
		if (mail_rcpt)
			curl_slist_free_all(mail_rcpt);
		curl_easy_cleanup(curl);
		curl = NULL;
		request->complete = true;
		request->in_progress = false;
		if (request->download_stream) {
			fclose(request->download_stream);
			request->download_stream = NULL;
		}
		return 0;
	}
	request->no_curl = true;
	return 0;
}

void internet_request::initial_setup() {
	curl = NULL;
	no_curl = false;
	complete = false;
	in_progress = false;
	abort_request = false;
	bytes_downloaded = 0;
	download_size = 0;
	download_percent = 0;
	bytes_uploaded = 0;
	upload_size = 0;
	upload_percent = 0;
	follow_redirects = true;
	keepalive = false;
	max_redirects = 50;
	status_code = 0;
	total_time = 0.0;
	url = "";
	final_url = "";
	if (path != "" && download_stream)
		fclose(download_stream);
	download_stream = NULL;
	path = "";
	auth_username = "";
	auth_password = "";
	mail_from = "";
	mail_to = "";
	headers.clear();
	payload = "";
	payload_cursor = 0;
	response_body = "";
	response_headers = "";
	debug_file = "";
	user_agent = "curl/7.81.0 (gzip)";
}
internet_request::internet_request(const std::string& url, bool autoperform) {
	RefCount = 1;
	initial_setup();
	this->url = url;
	if (autoperform && !perform())
		no_curl = true;
}
internet_request::internet_request(const std::string& url, const std::string& path, bool autoperform) {
	initial_setup();
	this->url = url;
	this->path = path;
	if (autoperform && !perform())
		no_curl = true;
	RefCount = 1;
}
internet_request::internet_request(const std::string& url, const std::string& username, const std::string& password, bool autoperform) {
	initial_setup();
	this->url = url;
	this->auth_username = username;
	this->auth_password = password;
	if (autoperform && !perform())
		no_curl = true;
	RefCount = 1;
}
void internet_request::AddRef() {
	asAtomicInc(RefCount);
}
void internet_request::Release() {
	if (asAtomicDec(RefCount) < 1) {
		abort_request = true;
		delete this;
	}
}
bool internet_request::perform() {
	if (in_progress)
		return false;
	if (complete) {
		complete = false;
		response_headers = "";
		response_body = "";
		payload_cursor = 0;
	}
	if (thread_create(internet_request_thread, this, THREAD_STACK_SIZE_DEFAULT) == NULL)
		return false;
	return true;
}
bool internet_request::perform(const std::string& URL) {
	if (in_progress)
		return false;
	this->url = URL;
	return perform();
}
bool internet_request::perform(const std::string& URL, const std::string& path) {
	if (in_progress)
		return false;
	this->url = URL;
	this->path = path;
	return perform();
}
bool internet_request::post(const std::string& URL, const std::string& payload, const std::string& path) {
	if (in_progress)
		return false;
	this->url = URL;
	this->payload = payload;
	if (path != "")
		this->path = path;
	return perform();
}
bool internet_request::mail(const std::string& URL, const std::string& from, const std::string& to, const std::string& payload) {
	if (in_progress)
		return false;
	this->url = URL;
	this->mail_from = from;
	this->mail_to = to;
	this->payload = payload;
	return perform();
}
void internet_request::set_url(const std::string& url) {
	if (in_progress) return;
	this->url = url;
}
void internet_request::set_path(const std::string& path) {
	if (in_progress) return;
	this->path = path;
}
void internet_request::set_authentication(std::string username, std::string password) {
	if (in_progress) return;
	this->auth_username.resize(0);
	this->auth_username += username;
	this->auth_password.resize(0);
	this->auth_password += password;
}
void internet_request::set_payload(const std::string& payload) {
	if (in_progress) return;
	this->payload = payload;
}
void internet_request::set_mail(const std::string& from, const std::string& to) {
	if (in_progress) return;
	this->mail_from = from;
	this->mail_to = to;
}
void internet_request::reset() {
	if (in_progress) return; // Temporary until implimentation of graceful thread shutdown mechonism.
	initial_setup();
}

internet_request* Script_internet_request_Factory() {
	return new internet_request();
}
internet_request* Script_internet_request_Factory_u(const std::string& url, bool autoperform) {
	return new internet_request(url, autoperform);
}
internet_request* Script_internet_request_Factory_u_p(const std::string& url, const std::string& path, bool autoperform) {
	return new internet_request(url, path, autoperform);
}
internet_request* Script_internet_request_Factory_u_u_p(const std::string& url, const std::string& username, const std::string& password, bool autoperform) {
	return new internet_request(url, username, password, autoperform);
}

void RegisterInternetPlugin(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_NET);
	engine->RegisterGlobalFunction("string curl_encode(const string& in)", asFUNCTION(url_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction("string curl_decode(const string& in)", asFUNCTION(url_decode), asCALL_CDECL);
	engine->RegisterObjectType("internet_request", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("internet_request", asBEHAVE_FACTORY, "internet_request @i()", asFUNCTION(Script_internet_request_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("internet_request", asBEHAVE_FACTORY, "internet_request @i(const string &in, bool = true)", asFUNCTION(Script_internet_request_Factory_u), asCALL_CDECL);
	engine->RegisterObjectBehaviour("internet_request", asBEHAVE_FACTORY, "internet_request @i(const string &in, const string &in, bool = true)", asFUNCTION(Script_internet_request_Factory_u_p), asCALL_CDECL);
	engine->RegisterObjectBehaviour("internet_request", asBEHAVE_FACTORY, "internet_request @i(const string &in, const string &in, const string &in, bool = true)", asFUNCTION(Script_internet_request_Factory_u_u_p), asCALL_CDECL);
	engine->RegisterObjectBehaviour("internet_request", asBEHAVE_ADDREF, "void f()", asMETHOD(internet_request, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("internet_request", asBEHAVE_RELEASE, "void f()", asMETHOD(internet_request, Release), asCALL_THISCALL);
	engine->RegisterObjectProperty("internet_request", "const bool no_curl", asOFFSET(internet_request, no_curl));
	engine->RegisterObjectProperty("internet_request", "const bool complete", asOFFSET(internet_request, complete));
	engine->RegisterObjectProperty("internet_request", "const bool in_progress", asOFFSET(internet_request, in_progress));
	engine->RegisterObjectProperty("internet_request", "bool follow_redirects", asOFFSET(internet_request, follow_redirects));
	engine->RegisterObjectProperty("internet_request", "int max_redirects", asOFFSET(internet_request, max_redirects));
	engine->RegisterObjectProperty("internet_request", "const double bytes_downloaded", asOFFSET(internet_request, bytes_downloaded));
	engine->RegisterObjectProperty("internet_request", "const double download_size", asOFFSET(internet_request, download_size));
	engine->RegisterObjectProperty("internet_request", "const double download_percent", asOFFSET(internet_request, download_percent));
	engine->RegisterObjectProperty("internet_request", "const double bytes_uploaded", asOFFSET(internet_request, bytes_uploaded));
	engine->RegisterObjectProperty("internet_request", "const double upload_size", asOFFSET(internet_request, upload_size));
	engine->RegisterObjectProperty("internet_request", "const double upload_percent", asOFFSET(internet_request, upload_percent));
	engine->RegisterObjectProperty("internet_request", "const int status_code", asOFFSET(internet_request, status_code));
	engine->RegisterObjectProperty("internet_request", "const double total_time", asOFFSET(internet_request, total_time));
	engine->RegisterObjectProperty("internet_request", "const string url", asOFFSET(internet_request, url));
	engine->RegisterObjectProperty("internet_request", "const string final_url", asOFFSET(internet_request, final_url));
	engine->RegisterObjectProperty("internet_request", "const string response_body", asOFFSET(internet_request, response_body));
	engine->RegisterObjectProperty("internet_request", "const string response_headers", asOFFSET(internet_request, response_headers));
	engine->RegisterObjectProperty("internet_request", "string debug_file", asOFFSET(internet_request, debug_file));
	engine->RegisterObjectProperty("internet_request", "string user_agent", asOFFSET(internet_request, user_agent));
	engine->RegisterObjectProperty("internet_request", "const string path", asOFFSET(internet_request, path));
	engine->RegisterObjectProperty("internet_request", "const string auth_username", asOFFSET(internet_request, auth_username));
	engine->RegisterObjectProperty("internet_request", "const string auth_password", asOFFSET(internet_request, auth_password));
	engine->RegisterObjectMethod("internet_request", "bool perform()", asMETHODPR(internet_request, perform, (), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "bool perform(const string &in)", asMETHODPR(internet_request, perform, (const std::string&), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "bool post(const string &in, const string &in, const string &in = '')", asMETHODPR(internet_request, post, (const std::string&, const std::string&, const std::string&), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "bool mail(const string &in, const string &in, const string &in, const string &in) const", asMETHODPR(internet_request, mail, (const std::string&, const std::string&, const std::string&, const std::string&), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void set_url(const string &in) const", asMETHODPR(internet_request, set_url, (const std::string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void set_path(const string &in) const", asMETHODPR(internet_request, set_path, (const std::string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void set_authentication(string, string)", asMETHODPR(internet_request, set_authentication, (std::string, std::string), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void set_payload(const string &in) const", asMETHODPR(internet_request, set_payload, (const std::string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void set_mail(const string &in, const string &in) const", asMETHODPR(internet_request, set_mail, (const std::string&, const std::string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void set_header(const string &in, const string& in) const", asMETHODPR(internet_request, set_header, (const std::string&, const std::string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("internet_request", "void reset() const", asMETHODPR(internet_request, reset, (), void), asCALL_THISCALL);
}

plugin_main(nvgt_plugin_shared* shared) {
	prepare_plugin(shared);
	RegisterInternetPlugin(shared->script_engine);
	return true;
}
