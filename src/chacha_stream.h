/* chacha_stream.h - Caturria's Monocypher chacha20 asset encrypting iostream implementation header
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
#include <Poco/BufferedStreamBuf.h>
#include <iostream>
class chacha_ostreambuf : public Poco::BasicBufferedStreamBuf<char, std::char_traits<char>>
{
	std::ostream *sink;
	uint8_t key[32];
	uint8_t nonce[24];
	uint8_t work[64]; // Will contain the most recent block of cyphertext.
	uint64_t counter;
	bool owns_sink;

public:
	chacha_ostreambuf(std::ostream &sink, const std::string &key, const std::string &nonce);
	virtual ~chacha_ostreambuf();
	void own_sink(bool owns);
	int writeToDevice(const char *buffer, std::streamsize length);
};
class chacha_istreambuf : public Poco::BasicBufferedStreamBuf<char, std::char_traits<char>>
{
	std::istream *source;
	uint8_t key[32];
	uint8_t nonce[24];
	uint8_t work[64];
	uint64_t counter;
	std::streamoff source_offset; // Location in the backing source after reading the nonce.
	bool owns_source;

public:
	// Note that the nonce is not passed in here because it's expected to be prepended to the payload itself.
	chacha_istreambuf(std::istream &source, const std::string &key);
	virtual ~chacha_istreambuf();
	void own_source(bool owns);
	int readFromDevice(char *buffer, std::streamsize length);
	std::streampos seekoff(std::streamoff off, std::ios_base::seekdir dir, std::ios_base::openmode which = std::ios_base::in);
	std::streampos seekpos(std::streampos pos, std::ios_base::openmode which = std::ios_base::in);
};
class chacha_istream : public std::istream
{
	chacha_istreambuf buf;

public:
	chacha_istream(std::istream &source, const std::string &key);
	virtual ~chacha_istream();
	std::istream &own_source(bool owns = true);
};
class chacha_ostream : public std::ostream
{
	static std::string generate_nonce();

public:
	chacha_ostream(std::ostream &sink, const std::string &key, const std::string &nonce);
	// Preferred overload where the nonce will be chosen for you (using rng_get_bytes):
	chacha_ostream(std::ostream &sink, const std::string &key);

	~chacha_ostream();
	std::ostream &own_sink(bool owns = true);
};