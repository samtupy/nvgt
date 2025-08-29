<?php

/* nvgt_aes_string.php - AES encryption/decryption routines that mirror nvgt's string_aes_encrypt/decrypt functions
 * You must enable php's openssl extension by uncommenting the extension=openssl line in php.ini for these to work.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

function string_pad(&$data, $blocklen = 16) {
	$datalen = strlen($data);
	if ($datalen < 1) return;
	$remainder = $blocklen - ($datalen % 16);
	if ($remainder == 0) $remainder = 16;
	$data .= str_repeat(chr($remainder), $remainder);
}

function string_unpad(&$data) {
	$datalen = strlen($data);
	if ($datalen < 1) return;
	$remainder = ord($data[$datalen -1]);
	if ($remainder >= $datalen) return;
	$data = substr($data, 0, -$remainder);
}

function string_aes_encrypt($data, $key) {
	string_pad($data);
	$key = hash("sha256", $key, true);
	$iv = "";
	for ($i = 0; $i < 16; $i++) $iv .= chr(ord($key[$i * 2]) ^ (4 * $i + 1));
	return openssl_encrypt($data, 'aes-256-cbc', $key, OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $iv);
}

function string_aes_decrypt($data, $key) {
	$key = hash("sha256", $key, true);
	$iv = "";
	for ($i = 0; $i < 16; $i++) $iv .= chr(ord($key[$i * 2]) ^ (4 * $i + 1));
	$data = openssl_decrypt($data, 'aes-256-cbc', $key, OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING, $iv);
	string_unpad($data);
	return $data;
}

