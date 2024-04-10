/* nvgt_config.h - user configuration header
 * This header contains user defined settings and functions for nvgt, such as custom security routines or the registrations for statically linked plugins.
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

// static plugins: When a plugin is compiled with the macro NVGT_PLUGIN_STATIC into a .lib or .a static library, a symbol from that library must be defined somewhere in the nvgt project so that the linker will load the library, thus performing the remainder of plugin registration via a static variable that will initialize at program startup.
#include "nvgt_plugin.h"
//static_plugin(git2nvgt)
//static_plugin(nvgt_curl)
//static_plugin(nvgt_sqlite)

// A simple integer can be used to xor encrypt numbers used to save bits of the bytecode location data.
#define NVGT_BYTECODE_NUMBER_XOR 47635
// Functions to encrypt/decrypt or otherwise mutate the Angelscript bytecode when creating executables. It is not recommended to use thee examples provided if you are compiling a custom build of NVGT, you should modify these and come up with your own security routines here!
// code: Pointer to the data which should be modified in place. If you need to resize it beyond alloc_size bytes, use the c realloc function to do so.
// size: Size of the provided code in bytes.
// alloc_size: Number of bytes allocated in the data block provided in the code argument, you should call realloc on the data if you need to increase the code size beyond this value.
// return: The size of the code as provided in the size argument, or a modified version of it if the function changed the size of the data.
#include <aes.hpp>
#include <Poco/SHA2Engine.h>
inline int angelscript_bytecode_decrypt(unsigned char* code, int size, int alloc_size) {
	unsigned char iv[16];
	char tmp[32];
	Poco::SHA2Engine hash;
	hash.update(tmp, snprintf(tmp, 32, "Kernel32.lib"));
	const unsigned char* key = hash.digest().data();
	for (int i = 0; i < 16; i++)
		iv[i] = key[i * 2 + 1] ^ (31 + i * 4);
	AES_ctx crypt;
	AES_init_ctx_iv(&crypt, key, iv);
	AES_CBC_decrypt_buffer(&crypt, code, size);
	return size - code[size - 1];
}
inline int angelscript_bytecode_encrypt(unsigned char* code, int size, int alloc_size) {
	unsigned char r = 16 - (size % 16);
	if (r == 0) r = 16;
	if (alloc_size - size < r) code = (unsigned char*)realloc(code, alloc_size + 16);
	for (int i = size; i < size + r; i++)
		code[i] = r;
	size += r;
	unsigned char iv[16];
	char tmp[32];
	Poco::SHA2Engine hash;
	hash.update(tmp, snprintf(tmp, 32, "Kernel32.lib"));
	const unsigned char* key = hash.digest().data();
	for (int i = 0; i < 16; i++)
		iv[i] = key[i * 2 + 1] ^ (31 + i * 4);
	AES_ctx crypt;
	AES_init_ctx_iv(&crypt, key, iv);
	AES_CBC_encrypt_buffer(&crypt, code, size);
	return size;
}

// NVGT's pack file object allows you to manipulate/usually encrypt the data going through it, below are the functions to do so. Feel free to rewrite them for increased security, or make them empty functions that directly return the b argument to disable this layer. At this time they only work on a char by char basis, meaning this should only be used for very basic encryption. This was left in the engine because it used to be the only means of encrypting pack files, so it's here for backwards compatibility. Disable it if you want to be able to make entirely decrypted pack files.
// b: byte being modified.
// o: Offset in data containing the byte.
// l: length of the data containing the byte.
// return: the modified byte.
inline unsigned char pack_char_encrypt(unsigned char b, unsigned int o, unsigned int l) {
	return (b + (unsigned char) o) & 0xff;
}
inline unsigned char pack_char_decrypt(unsigned char b, unsigned int o, unsigned int l) {
	return (b - (unsigned char) o) & 0xff;
}
// Same sort of decryption function as above, but for the sound object's memory streams. If the version of sound.load with the legacy_encrypt boolean is called with that bool set to true, the sound's data is run through this function as it is being processed, character by character. Encryption should be handled in your own packer in this case, the default example function simply subtracting 27 from each byte for decryption. Change if you intend to use for yourself!
inline unsigned char sound_data_char_decrypt(unsigned char b, unsigned int o, unsigned int l) {
	return b - 27;
}

