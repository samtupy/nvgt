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
#include <Poco/InflatingStream.h>
#include <Poco/DeflatingStream.h>
#include <Poco/StreamCopier.h>
#include "compression.h"
#include <istream>
#include <ostream>

std::string string_deflate(const std::string& str, int compressionlevel = -1) {
	std::stringstream istream(str);
	std::string output;
	Poco::DeflatingInputStream stream(istream, Poco::DeflatingStreamBuf::STREAM_ZLIB, compressionlevel);
	stream.exceptions(std::istream::failbit | std::istream::badbit); 
	stream >> output;
	return output;
}

std::string string_inflate(const std::string& str) {
	std::stringstream istream(str);
	std::string output;
	Poco::InflatingInputStream stream(istream, Poco::InflatingStreamBuf::STREAM_ZLIB);
	stream.exceptions(std::istream::failbit | std::istream::badbit); 
	stream >> output;
	stream.close();
	return output;
}

void RegisterScriptCompression(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction("string string_deflate(const string& in, int = 9)", asFUNCTION(string_deflate), asCALL_CDECL);
	engine->RegisterGlobalFunction("string string_inflate(const string& in)", asFUNCTION(string_inflate), asCALL_CDECL);
}
