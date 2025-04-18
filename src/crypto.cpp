/* crypto.cpp - encryption and decryption functions code
 * Warning, the author of this code is not an expert on encryption. While the functions here will protect your data, they have by no means been battletested by a cryptography expert and/or they may not follow standards perfectly. Please feel free to report any vulnerabilities.
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

#include "crypto.h"
#include "aes.hpp"
#include <string>
#include <cstring>
#include <sstream>
#include <rng_get_bytes.h>
#include <obfuscate.h>
#include <Poco/SHA2Engine.h>
#include "monocypher.h"

void string_pad(std::string& str, int blocksize = 16) {
	if (str.size() == 0) return;
	int remainder = 16 - (str.size() % 16);
	if (remainder == 0) remainder = 16;
	str += std::string(remainder, (char)remainder);
}
void string_unpad(std::string& str) {
	if (str.size() == 0) return;
	if (str[str.size() - 1] > 16 || str[str.size() - 1] >= str.size()) {
		str.resize(0);
		return;
	}
	int new_size = str.size() - (str[str.size() - 1]);
	if (new_size < 0) new_size = 0;
	str.resize(new_size);
}
std::string string_aes_encrypt(const std::string& original_text, std::string key) {
	std::string text = original_text;
	Poco::SHA2Engine hash;
	hash.update(key);
	const unsigned char* key_hash = hash.digest().data();
	key.clear();
	key.shrink_to_fit();
	unsigned char iv[16];
	for (int i = 0; i < 16; i++)
		iv[i] = key_hash[i * 2] ^ (4 * i + 1);
	AES_ctx crypt;
	AES_init_ctx_iv(&crypt, key_hash, iv);
	string_pad(text);
	AES_CBC_encrypt_buffer(&crypt, (uint8_t*)&text.front(), text.size());
	memset(iv, 0, sizeof(iv));
	memset(&crypt, 0, sizeof(AES_ctx));
	return text;
}
std::string string_aes_encrypt_r(const std::string& text, std::string& key) {
	// Sorry I know this seems pointless, ran into some sort of issue with constant strings and Angelscript function registration 2 years ago when this was implemented. I probably know enough now to get rid of this redundant function but don't want to risk breaking something at the time of writing this comment, so later.
	std::string t = text;
	string_aes_encrypt(t, key);
	return t;
}
std::string string_aes_decrypt(const std::string& original_text, std::string key) {
	if (original_text.size() % 16 != 0) return "";
	std::string text = original_text;
	Poco::SHA2Engine hash;
	hash.update(key);
	const unsigned char* key_hash = hash.digest().data();
	unsigned char iv[16];
	for (int i = 0; i < 16; i++)
		iv[i] = key_hash[i * 2] ^ (4 * i + 1);
	key.clear();
	key.shrink_to_fit();
	AES_ctx crypt;
	AES_init_ctx_iv(&crypt, key_hash, iv);
	AES_CBC_decrypt_buffer(&crypt, (uint8_t*)&text.front(), text.size());
	memset(iv, 0, sizeof(iv));
	memset(&crypt, 0, sizeof(AES_ctx));
	string_unpad(text);
	return text;
}
std::string string_aes_decrypt_r(const std::string& text, std::string& key) {
	std::string t = text;
	string_aes_decrypt(t, key);
	return t;
}

std::string random_bytes(asUINT len) {
	if (len < 1) return "";
	std::string ret(len, '\0');
	if (rng_get_bytes((unsigned char *)&ret[0], len) != len)
		return "";
	return ret;
}

// Caturria's Monocypher chacha20 asset encrypting iostream implementation
static const int32_t chacha_iostream_magic = 0xAceFaded; // We prepend this to the first block of plaintext before encrypting to help identify the resource as a NVGT encrypted asset.
static const int nonce_length = 24;
chacha_ostreambuf::chacha_ostreambuf(std::ostream &sink, const std::string &key, const std::string &nonce)
	: BasicBufferedStreamBuf(64, std::ios_base::out) {

	if (key.empty())
		throw std::invalid_argument("Key must not be blank.");
	if (nonce.length() != nonce_length)
		throw std::invalid_argument("Incorrect nonce length.");
	// Todo discuss this with people. Blake2B is not appropriate for key derivation because it's fast, but for a game that needs to load thousands of assets in seconds, we can't really afford something like Argon2 either. We should probably decide on a default function and expose it in nvgt_config.h for commercial devs to customize.
	crypto_blake2b(this->key, 32, (uint8_t *)key.data(), key.size());
	memcpy(this->nonce, nonce.data(), 24);
	// Put the nonce directly into the sink in cleartext.
	sink.write((const char *)this->nonce, nonce_length);
	// Encrypt the magic asset identifier:
	sputn((const char *)&chacha_iostream_magic, sizeof(chacha_iostream_magic));

	counter = 0;
	this->sink = &sink;
	owns_sink = false;
}
chacha_ostreambuf::~chacha_ostreambuf() {

	// Should explicitly destroy the contents of the internal buffers.
	crypto_wipe((void *)key, 32);
	crypto_wipe((void *)nonce, nonce_length);
	if (owns_sink)
		delete sink;
}
void chacha_ostreambuf::own_sink(bool owns) {
	this->owns_sink = owns;
}
int chacha_ostreambuf::writeToDevice(const char *buffer, std::streamsize length) {

	counter = crypto_chacha20_x((uint8_t *)work, (const uint8_t *)buffer, length, key, nonce, counter);

	sink->write((const char *)work, length);
	// Q: what am I expected to return here? The Poco docs don't say. A: count of bytes written... but why is the return type shorter than the length argument?
	return (int)length;
}
std::streampos chacha_ostreambuf::seekoff(std::streamoff off, std::ios_base::seekdir dir, std::ios_base::openmode which) {
	// Support 0 cur to enable tellp().
	if (dir == std::ios_base::cur && off == 0)

		return sink->tellp() + std::streampos(in_avail() - nonce_length);
	if (dir == std::ios_base::beg && off == 0)
		return seekpos(0);
	return -1;
}
std::streampos chacha_ostreambuf::seekpos(std::streampos pos, std::ios_base::openmode which) {
	// Only support returning to 0.
	if (pos != 0)
		return -1;
	this->sync();
	// Seek the sink back to just after the nonce:
	sink->seekp(nonce_length);
	// Now rewrite the magic and reset the counter.
	counter = 0;
	sputn((const char *)&chacha_iostream_magic, sizeof(chacha_iostream_magic));
	return 0;
}

chacha_istreambuf::chacha_istreambuf(std::istream &source, const std::string &key)
	: BasicBufferedStreamBuf(8192 + 4, std::ios_base::in) {

	// Note: we've added four extra bytes of buffer because Poco appears to always request four bytes fewer than what the buffer capacity is, and the source material can only be read in 64-byte blocks.
	if (key.empty())
		throw std::invalid_argument("Key cannot be blank.");

	// Todo discuss this with people. Blake2B is not appropriate for key derivation because it's fast, but for a game that needs to load thousands of assets in seconds, we can't really afford something like Argon2 either. We should probably decide on a default function and expose it in nvgt_config.h for commercial devs to customize.
	crypto_blake2b(this->key, 32, (uint8_t *)key.data(), key.size());

	// Consume the nonce directly from the source.
	source.read((char *)nonce, 24);
	if (source.gcount() != 24)
		throw std::invalid_argument("Unexpected error or end of stream during initialization.");

	// The source is now positioned at the start of the payload. Capture this offset and use it later to calculate seek positions.
	source_offset = source.tellg();
	this->source = &source;
	counter = 0;
	// First four bytes should be the magic asset identifier.
	int32_t magic;
	sgetn((char *)&magic, 4);
	if (magic != chacha_iostream_magic) {
		this->source = NULL; // Disown.
		throw std::invalid_argument("This is not a valid asset stream.");
	}
	owns_source = false;
}
chacha_istreambuf::~chacha_istreambuf() {

	crypto_wipe(work, 64);
	crypto_wipe(key, 32);
	crypto_wipe(nonce, 24);

	if (owns_source)
		delete source;
}
void chacha_istreambuf::own_source(bool owns) {
	owns_source = owns;
}
int chacha_istreambuf::readFromDevice(char *buffer, std::streamsize length) {

	if (length % 64 != 0) {
		return -1; // Shouldn't happen, but cross this bridge if we get there (this is better than outputting garbage).
	}
	// Sanity check: we must either be 64-byte aligned or EOF. Also our counter must be in sync with our position in the stream.
	std::streampos true_pos = source->tellg() - source_offset;
	if (true_pos % 64 != 0 || true_pos / 64 != counter)
		return -1;
	source->read((char *)buffer, length);
	length = source->gcount();
	if (length == 0) {
		return -1; // EOF.
	}
	counter = crypto_chacha20_x((uint8_t *)buffer, (const uint8_t *)buffer, length, key, nonce, counter);
	return (int)length;
}
std::streampos chacha_istreambuf::seekoff(std::streamoff off, std::ios_base::seekdir dir, std::ios_base::openmode which) {
	// Ignore 0 cur... Istream makes this call to find out where it is in the stream.
	if (off == 0 && dir == std::ios_base::cur) {
		source->clear();
		return (uint64_t)source->tellg() - source_offset - 4 - in_avail();
	}
	// Commenting this heavily because this genuinely is no picnic.
	// First, we need to clear any failure state that the underlying stream might have:
	source->clear();
	// Deal only with the end direction; beg and cur can be mapped to a regular seekpos call.
	if (dir == std::ios_base::beg)
		return seekpos(off);
	else if (dir == std::ios_base::cur) {
		// Current position in source, plus distance we want to jump, minus position in source where we started, minus size of asset header, minus number of bytes we've prepared but haven't delivered to the caller yet.
		return seekpos((uint64_t)source->tellg() + off - source_offset - 4 - in_avail());
	}
	// If we're here it means the caller has requested to seek to an offset from the end of the stream.
	// Now we naively seek the source to our target byte, because we want to convert our offset and direction into an absolute position.
	source->seekg(off, dir);
	// If the seek failed for any reason, the source will be in a failure state, in which case we want to enter a failure state ourselves.
	if (!source->good())
		return -1;
	// Now just defer to seekpos. Don't forget about the pre-stream source data and asset header here.
	return seekpos((uint64_t)source->tellg() - source_offset - 4);
}
std::streampos chacha_istreambuf::seekpos(std::streampos pos, std::ios_base::openmode which) {

	// Commenting this heavily because this genuinely is no picnic.
	// First, we need to clear any failure state that the underlying stream might have:
	source->clear();
	/*
	We now know exactly where the caller hopes to seek to.
	But ChaCha works on 64 - byte blocks, and we can't start decrypting in the middle of one.
	We also have to tell ChaCha which block number we're going back to or it won't decrypt our data correctly.
	Finally, we need to take the asset header (four bytes) into account.
	*/
	pos += 4;
	counter = (uint64_t)pos / 64;
	// Final seek to the target block boundary. Don't forget about the arbitrary source offset that needs to be taken into account as well (at least the 24-byte nonce, and maybe even another sum of arbitrary data that could have come before the start of our stream).
	source->seekg(counter * 64 + source_offset);

	if (!source->good())
		return -1;
	// Now we're at the closest byte that we can seek to. Empty the buffer of stale data:
	this->setg(NULL, NULL, NULL);
	// Then fill it up again with fresh data:
	underflow();
	// Finally, throw away however many bytes stand between the start of the block we just selected and the byte that was actually requested by the caller.

	gbump((int)pos - (((int)pos / 64) * 64));
	return counter * 64; // Block offset. Istream will consider its internal buffers when reporting the true position to the caller.
}

chacha_istream::chacha_istream(std::istream &source, const std::string &key)
	: buf(source, key),
	  basic_istream(&buf)

{
}
chacha_istream::~chacha_istream() {
	// delete rdbuf();
}
std::istream &chacha_istream::own_source(bool owns) {
	chacha_istreambuf *buf = static_cast<chacha_istreambuf *>(rdbuf());
	if (buf != nullptr)
		buf->own_source(owns);
	return *this;
}
std::string chacha_ostream::generate_nonce() {
	unsigned char nonce[24];
	unsigned long result = rng_get_bytes(nonce, 24);
	if (result != 24)
		throw new std::runtime_error("Could not obtain required number of bytes for nonce.");
	return std::string((const char *)nonce, 24);
}
chacha_ostream::chacha_ostream(std::ostream &sink, const std::string &key, const std::string &nonce)
	: basic_ostream(new chacha_ostreambuf(sink, key, nonce)) {
}
chacha_ostream::chacha_ostream(std::ostream &sink, const std::string &key)
	: basic_ostream(new chacha_ostreambuf(sink, key, generate_nonce())) {
}
chacha_ostream::~chacha_ostream() {
	flush();
	delete rdbuf();
}
std::ostream &chacha_ostream::own_sink(bool owns) {
	chacha_ostreambuf *buf = static_cast<chacha_ostreambuf *>(rdbuf());
	if (buf != nullptr)
		buf->own_sink(owns);
	return *this;
}


void RegisterScriptCrypto(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction(_O("string string_aes_encrypt(const string&in plaintext, string key)"), asFUNCTION(string_aes_encrypt), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_aes_decrypt(const string&in ciphertext, string)"), asFUNCTION(string_aes_decrypt), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string random_bytes(uint count)"), asFUNCTION(random_bytes), asCALL_CDECL);
}
