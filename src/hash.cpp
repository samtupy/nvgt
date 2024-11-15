/* hash.cpp - code for hashing related functions mostly wrapping poco
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
#include <angelscript.h>
#include <enet.h>
#include <obfuscate.h>
#include <Poco/HMACEngine.h>
#include <Poco/MD5Engine.h>
#include <Poco/SHA1Engine.h>
#include <Poco/SHA2Engine.h>

std::string md5(const std::string& message, bool binary) {
	Poco::MD5Engine engine;
	engine.update(message);
	auto digest = engine.digest();
	if (binary)
		return std::string((const char*)&digest[0], digest.size());
	else
		return Poco::DigestEngine::digestToHex(digest);
}
std::string sha1(const std::string& message, bool binary) {
	Poco::SHA1Engine engine;
	engine.update(message);
	auto digest = engine.digest();
	if (binary)
		return std::string((const char*)&digest[0], digest.size());
	else
		return Poco::DigestEngine::digestToHex(digest);
}
std::string sha224(const std::string& message, bool binary) {
	Poco::SHA2Engine engine(Poco::SHA2Engine::SHA_224);
	engine.update(message);
	auto digest = engine.digest();
	if (binary)
		return std::string((const char*)&digest[0], digest.size());
	else
		return Poco::DigestEngine::digestToHex(digest);
}
std::string sha256(const std::string& message, bool binary) {
	Poco::SHA2Engine engine(Poco::SHA2Engine::SHA_256);
	engine.update(message);
	auto digest = engine.digest();
	if (binary)
		return std::string((const char*)&digest[0], digest.size());
	else
		return Poco::DigestEngine::digestToHex(digest);
}
std::string sha384(const std::string& message, bool binary) {
	Poco::SHA2Engine engine(Poco::SHA2Engine::SHA_384);
	engine.update(message);
	auto digest = engine.digest();
	if (binary)
		return std::string((const char*)&digest[0], digest.size());
	else
		return Poco::DigestEngine::digestToHex(digest);
}
std::string sha512(const std::string& message, bool binary) {
	Poco::SHA2Engine engine(Poco::SHA2Engine::SHA_512);
	engine.update(message);
	auto digest = engine.digest();
	if (binary)
		return std::string((const char*)&digest[0], digest.size());
	else
		return Poco::DigestEngine::digestToHex(digest);
}

std::string u32beToByteString(uint32_t num) {
	std::string ret;
	ret.push_back((num >> 24) & 0xFF);
	ret.push_back((num >> 16) & 0xFF);
	ret.push_back((num >> 8) & 0xFF);
	ret.push_back((num >> 0) & 0xFF);
	return ret;
}
std::string u64beToByteString(uint64_t num) {
	std::string left = u32beToByteString((num >> 32) & 0xFFFFFFFF);
	std::string right = u32beToByteString((num >> 0) & 0xFFFFFFFF);
	return left + right;
}

uint32_t hotp(const std::string& key, uint64_t counter, uint32_t digitCount) {
	std::string msg = u64beToByteString(counter);
	Poco::HMACEngine<Poco::SHA1Engine> engine(key);
	engine.update(msg);
	auto hmac = engine.digest();

	uint32_t digits10 = 1;
	for (size_t i = 0; i < digitCount; ++i)
		digits10 *= 10;

	// fetch the offset (from the last nibble)
	uint8_t offset = hmac[hmac.size() - 1] & 0x0F;

	// fetch the four bytes from the offset
	Poco::DigestEngine::Digest fourWord(hmac.begin() + offset, hmac.begin() + offset + 4);

	// turn them into a 32-bit integer
	uint32_t ret = (fourWord[0] << 24) | (fourWord[1] << 16) | (fourWord[2] << 8) | (fourWord[3] << 0);

	// snip off the MSB (to alleviate signed/unsigned troubles) and calculate modulo digit count
	return (ret & 0x7fffffff) % digits10;
}

unsigned int crc32(const std::string& data) {
	if (data == "") return 0;
	ENetBuffer b;
	b.data = (void*)&data[0];
	b.dataLength = data.size();
	return enet_crc32(&b, 1);
}

void RegisterScriptHash(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction(_O("string string_hash_md5(const string& in data, bool binary = false)"), asFUNCTION(md5), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_hash_sha1(const string& in data, bool binary = false)"), asFUNCTION(sha1), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_hash_sha224(const string& in data, bool binary = false)"), asFUNCTION(sha224), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_hash_sha256(const string& in data, bool binary = false)"), asFUNCTION(sha256), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_hash_sha384(const string& in data, bool binary = false)"), asFUNCTION(sha384), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_hash_sha512(const string& in data, bool binary = false)"), asFUNCTION(sha512), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint crc32(const string& in data)"), asFUNCTION(crc32), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint HOTP(const string& in key, uint64 counter, uint digits = 6)"), asFUNCTION(hotp), asCALL_CDECL);
}
