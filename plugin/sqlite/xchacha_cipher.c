/* xchacha_cipher.c - implementation of XChaCha20 cipher for DB engine (implementation file)
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

#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <string.h>
#include "sqlite3.h"
#include "monocypher.h"
#include "monocypher-ed25519.h"
#include "rng_get_bytes.h"

struct xchacha20_cipher {
	uint8_t key[32];
	uint8_t salt[16];
	uint64_t counter;
};

static void* alloc_cipher(sqlite3*db) {
	struct xchacha20_cipher * ctx = (struct xchacha20_cipher*)sqlite3_malloc(sizeof(struct xchacha20_cipher));
	if (!ctx) return NULL;
	crypto_wipe(ctx, sizeof(struct xchacha20_cipher));
	return ctx;
}

static void free_cipher(void* cipher) {
	if (!cipher) return;
	struct xchacha20_cipher* ctx = (struct xchacha20_cipher*)cipher;
	crypto_wipe(ctx, sizeof(struct xchacha20_cipher));
	sqlite3_free(ctx);
}

static void clone_cipher(void* cipherTo, void* cipherFrom) {
	if (!cipherFrom || !cipherTo) return;
	struct xchacha20_cipher* c1 = (struct xchacha20_cipher*)cipherFrom;
	struct xchacha20_cipher* c2 = (struct xchacha20_cipher*)cipherTo;
	memcpy(c2->key, c1->key, 32);
	memcpy(c2->salt, c1->salt, 16);
	c2->counter = c1->counter;
}

static int cipher_get_legacy(void* cipher) {
	return 0;
}

static int get_page_size(void* cipher) {
	return 4096;
}

static int get_reserved_size(void *cipher) {
	return 40;
}

static unsigned char* get_salt(void* cipher) {
	if (!cipher) return NULL;
	struct xchacha20_cipher* c = (struct xchacha20_cipher*)cipher;
	return c->salt;
}

static void generate_key(void* cipher, BtSharedMC* PBt, char* userPassword, int passwordLength, int rekey, unsigned char* salt) {
	struct xchacha20_cipher* c = (struct xchacha20_cipher*)cipher;
	if (rekey) {
		while (rng_get_bytes(c->salt, 16) != 16);
	} else if (salt != NULL) {
		memcpy(c->salt, salt, 16);
	}
	crypto_argon2_config config;
	config.algorithm = CRYPTO_ARGON2_I;
	config.nb_blocks = 7168;
	config.nb_passes = 5;
	config.nb_lanes = 1;
	crypto_argon2_inputs inputs;
	inputs.pass = (uint8_t*)userPassword;
	inputs.pass_size = passwordLength;
	inputs.salt = c->salt;
	inputs.salt_size = 16;
	crypto_argon2_extras extras = {0};
	uint8_t key[32];
	uint8_t* work_area = sqlite3_malloc(config.nb_blocks*1024);
	crypto_argon2(key, 32, work_area, config, inputs, extras);
	sqlite3_free(work_area);
	crypto_sha512_hkdf(c->key, 32, key, 32, c->salt, 16, NULL, 0);
}

static int encrypt_page(void* cipher, int page, unsigned char* data, int len, int reserved) {
	struct xchacha20_cipher* c = (struct xchacha20_cipher*)cipher;
	if (c->counter == ULLONG_MAX) {
		sqlite3_log(SQLITE_ERROR, "Nonce overflow in encryption/decryption routine; aborting");
		return SQLITE_ABORT;
	}
	if (reserved != 40 || (len - reserved) < 1 || page < 0) {
		return SQLITE_IOERR_CORRUPTFS;
	}
	const int actual_size = len - reserved;
	uint8_t nonce[24];
	memset(nonce, 0, 24);
	const uint64_t n = c->counter;
	const uint64_t n2 = (uint64_t)page;
	nonce[8] = (n >> (8 * 0)) & 0xff;
	nonce[9] = (n >> (8 * 1)) & 0xff;
	nonce[10] = (n >> (8 * 2)) & 0xff;
	nonce[11] = (n >> (8 * 3)) & 0xff;
	nonce[12] = (n >> (8 * 4)) & 0xff;
	nonce[13] = (n >> (8 * 5)) & 0xff;
	nonce[14] = (n >> (8 * 6)) & 0xff;
	nonce[15] = (n >> (8 * 7)) & 0xff;
	nonce[16] = (n2 >> (8 * 0)) & 0xff;
	nonce[17] = (n2 >> (8 * 1)) & 0xff;
	nonce[18] = (n2 >> (8 * 2)) & 0xff;
	nonce[19] = (n2 >> (8 * 3)) & 0xff;
	nonce[20] = (n2 >> (8 * 4)) & 0xff;
	nonce[21] = (n2 >> (8 * 5)) & 0xff;
	nonce[22] = (n2 >> (8 * 6)) & 0xff;
	nonce[23] = (n2 >> (8 * 7)) & 0xff;
	if (page == 1) {
		crypto_aead_lock(data + 24, (uint8_t*)data[actual_size + 24], c->key, nonce, NULL, 0, (uint8_t*)data+24, actual_size - 24);
		memcpy(c->salt, data, 16);
	} else
		crypto_aead_lock(data, (uint8_t*)data[actual_size + 24], c->key, nonce, NULL, 0, (uint8_t*)data, actual_size);
	for (int i = 0; i < 24; ++i) {
		data[actual_size + i] = nonce[i];
	}
	c->counter++;
	return SQLITE_OK;
}

static int decrypt_page(void* cipher, int page, unsigned char* data, int len, int reserved, int hmac_check) {
	struct xchacha20_cipher* c = (struct xchacha20_cipher*)cipher;
	if (reserved != 40 || ((len - reserved) < 1) || page < 0) {
		return SQLITE_IOERR_CORRUPTFS;
	}
	const int actual_size = len - reserved;
	uint8_t nonce[24];
	memset(nonce, 0, 24);
	for (int i = 0; i < 24; ++i) {
		nonce[i] = data[actual_size + i];
	}
	uint8_t mac[16];
	memset(mac, 0, 16);
	for (int i = 0; i < 16; ++i) {
		mac[i] = data[actual_size + 24 + i];
	}
	if (page == 1) {
		if (crypto_aead_unlock(data + 24, mac, c->key, nonce, NULL, 0, data + 24, actual_size - 24) == -1) {
			return SQLITE_IOERR_CORRUPTFS;
		}
		for (int i = 0; i < 16; ++i)
			c->salt[i] = data[i];
	} else
		if (crypto_aead_unlock(data, mac, c->key, nonce, NULL, 0, data, actual_size) == -1) {
			return SQLITE_IOERR_CORRUPTFS;
		}

	return SQLITE_OK;
}

static const CipherDescriptor XChaCha20Descriptor = {
	"xchacha20poly1305",
	alloc_cipher,
	free_cipher,
	clone_cipher,
	cipher_get_legacy,
	get_page_size,
	get_reserved_size,
	get_salt,
	generate_key,
	encrypt_page,
	decrypt_page
};

static CipherParams XChaCha20Params[] = {
	{ "", 0, 0, 0, 0 }
};

int nvgt_sqlite_register_cipher() {
	return sqlite3mc_register_cipher(&XChaCha20Descriptor, XChaCha20Params, 1);
}
