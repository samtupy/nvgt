/* compression.cpp - string_deflate and string_inflate functions
 * original gist copyright 2007 Timo Bingmann <tb@panthema.net> under the boost license: https://gist.github.com/gomons/9d446024fbb7ccb6536ab984e29e154a
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
#include <cstring>
#include <stdexcept>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <Poco/zlib.h>
#include "compression.h"

std::string string_deflate(const std::string& str, int compressionlevel = Z_BEST_COMPRESSION) {
	z_stream zs;// z_stream is zlib's control structure
	memset(&zs, 0, sizeof(zs));

	if (deflateInit(&zs, compressionlevel) != Z_OK)
		return "";

	zs.next_in = (Bytef*)str.data();
	zs.avail_in = str.size(); // set the z_stream's input

	int ret;
	char outbuffer[32768];
	std::string outstring;

	// retrieve the compressed bytes blockwise
	do {
		zs.next_out = reinterpret_cast<Bytef*>(outbuffer);
		zs.avail_out = sizeof(outbuffer);

		ret = deflate(&zs, Z_FINISH);

		if (outstring.size() < zs.total_out) {
			// append the block to the output string
			outstring.append(outbuffer, zs.total_out - outstring.size());
		}
	} while (ret == Z_OK);

	deflateEnd(&zs);

	if (ret != Z_STREAM_END) { // an error occurred that was not EOF
		/*std::ostringstream oss;
		oss << "Exception during zlib compression: (" << ret << ") " << zs.msg;
		throw(std::runtime_error(oss.str()));
		*/
		return "";
	}

	return outstring;
}

std::string string_inflate(const std::string& str) {
	z_stream zs;// z_stream is zlib's control structure
	memset(&zs, 0, sizeof(zs));

	if (inflateInit(&zs) != Z_OK)
		return "";

	zs.next_in = (Bytef*)str.data();
	zs.avail_in = str.size();

	int ret;
	char outbuffer[32768];
	std::string outstring;

	// get the decompressed bytes blockwise using repeated calls to inflate
	do {
		zs.next_out = reinterpret_cast<Bytef*>(outbuffer);
		zs.avail_out = sizeof(outbuffer);

		ret = inflate(&zs, 0);

		if (outstring.size() < zs.total_out)
			outstring.append(outbuffer, zs.total_out - outstring.size());

	} while (ret == Z_OK);

	inflateEnd(&zs);

	if (ret != Z_STREAM_END) { // an error occurred that was not EOF
		/*std::ostringstream oss;
		oss << "Exception during zlib decompression: (" << ret << ") "
		<< zs.msg;
		throw(std::runtime_error(oss.str()));
		*/
		return "";
	}

	return outstring;
}

void RegisterScriptCompression(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction("string string_deflate(const string& in, int = 9)", asFUNCTION(string_deflate), asCALL_CDECL);
	engine->RegisterGlobalFunction("string string_inflate(const string& in)", asFUNCTION(string_inflate), asCALL_CDECL);
}
