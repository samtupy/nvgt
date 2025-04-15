/* hash.h - header for hashing related functions
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
#include <iostream>
#include <string>
#include <Poco/BufferedStreamBuf.h>
#include <Poco/Checksum.h>
std::string sha256(const std::string& message, bool binary);

class asIScriptEngine;

/**
 * A simple istream/ ostream pair that passes data through a checksum before writing or returning it provided by Caturria.
 * does not take ownership of its attached stream.
*/
class checksum_ostreambuf : public Poco::BasicBufferedStreamBuf<char, std::char_traits<char>> {
	Poco::Checksum check;
	std::ostream *sink;
public:
	checksum_ostreambuf(std::ostream &sink);
	~checksum_ostreambuf();
	int writeToDevice(const char *buffer, std::streamsize length);
	uint32_t get_checksum();
};
class checksum_ostream : public std::ostream {
public:
	checksum_ostream(std::ostream &sink);
	~checksum_ostream();
	uint32_t get_checksum();
};
class checksum_istreambuf : public Poco::BasicBufferedStreamBuf<char, std::char_traits<char>> {
	Poco::Checksum check;
	std::istream *source;
public:
	checksum_istreambuf(std::istream &source);
	~checksum_istreambuf();
	int readFromDevice(char *buffer, std::streamsize length);
	uint32_t get_checksum();
};
class checksum_istream : public std::istream {
	std::istream *source;
public:
	checksum_istream(std::istream &source);
	~checksum_istream();
	std::streampos tellg();
	uint32_t get_checksum();
};


void RegisterScriptHash(asIScriptEngine* engine);
