/* internet.h - libcurl wrapper plugin header
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

#pragma once
#include <string>
#include <map>
#include <vector>
#include <curl.h>
#include "../../src/nvgt_plugin.h"

class internet_request {
	void initial_setup();
	int RefCount;
public:
	CURL* curl;
	bool no_curl; // If true, indicates that there was an error initializing curl for this request.
	bool complete; // If true, the request has completed and it is safe to use this object's response variables.
	bool in_progress; // If true, you should never touch any response variables in this object as they may actively be getting written to from the request thread.
	bool abort_request;
	double bytes_downloaded;
	double download_size;
	double download_percent;
	double bytes_uploaded;
	double upload_size;
	double upload_percent;
	bool follow_redirects; // true by default, allows curl to follow location headers.
	bool keepalive; // Set to true for ftp or any other contiguous connection.
	int max_redirects; // 50 by default, the maximum number of location headers to follow.
	int status_code; // Contains the status code of the request.
	double total_time; // Contains the time the request took to execute.
	std::string url; // Original URL of request.
	std::string final_url;
	std::string response_body; // Contains the text of the response.
	std::string response_headers; // Contains all headers sent in the response.
	std::string user_agent;
	std::string path; // If this is set, requests will save to a file at this path rather than to response_body. response_headers will still be available.
	std::string auth_username;
	std::string auth_password;
	std::string payload; // If this is set, request becomes post and payload is sent.
	std::string mail_from;
	std::string mail_to;
	std::string debug_file;
	unsigned int payload_cursor;
	FILE* download_stream; // Used if path is set.
	std::map<std::string, std::string> headers;
	internet_request() { RefCount = 1; initial_setup(); }
	internet_request(const std::string& url, bool autoperform = true);
	internet_request(const std::string& url, const std::string& path, bool autoperform = true);
	internet_request(const std::string& url, const std::string& auth_username, const std::string& auth_password, bool autoperform = true);
	void AddRef();
	void Release();
	bool perform();
	bool perform(const std::string& url);
	bool perform(const std::string& url, const std::string& path);
	bool post(const std::string& url, const std::string& payload, const std::string& path = "");
	bool mail(const std::string& url, const std::string& from, const std::string& to, const std::string& payload);
	void set_url(const std::string& url);
	void set_path(const std::string& path);
	void set_authentication(std::string username, std::string password);
	void set_payload(const std::string& payload);
	void set_mail(const std::string& from, const std::string& to);
	void set_header(const std::string& key, const std::string& value = "") { headers[key] = value; }
	void reset();
};

void RegisterInternet(asIScriptEngine* engine);
