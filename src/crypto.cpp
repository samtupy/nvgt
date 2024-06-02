/* crypto.cpp - AES encryption and decryption functions code
 * Warning, the author of this code is not an expert on encryption. While the functions here will protect your data, they have by no means been battletested by a cryptography expert and/or they may not follow standards perfectly. Please feel free to report any vulterabilities.
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
#include <rng_get_bytes.h>
#include <obfuscate.h>
#include <Poco/SHA2Engine.h>

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
	if (rng_get_bytes((unsigned char*)&ret[0], len) != len)
		return "";
	return ret;
}

void RegisterScriptCrypto(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction(_O("string string_aes_encrypt(const string&in, string)"), asFUNCTION(string_aes_encrypt), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_aes_decrypt(const string&in, string)"), asFUNCTION(string_aes_decrypt), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string random_bytes(uint)"), asFUNCTION(random_bytes), asCALL_CDECL);
}
