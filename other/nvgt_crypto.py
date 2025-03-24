# This script was created by me with the assistance of GPT-4.
# While GPT-4 handled much of the heavy lifting, I contributed my own knowledge and understanding to refine it.
#
# The purpose of this script is to encrypt and decrypt data in a way that is compatible with NVGT's encryption system.
# This means you can encrypt data in Python, pass it to NVGT for decryption, and vice versa, especially if you wish to use a bridge between the two.

from Crypto.Cipher import AES
from Crypto.Hash import SHA256
import hashlib

def pad(data, block_size=16):
    """PKCS7-like padding"""
    remainder = block_size - (len(data) % block_size)
    return data + bytes([remainder] * remainder)

def unpad(data):
    """Remove PKCS7-like padding"""
    if not data:
        return b""
    pad_length = data[-1]
    if pad_length > 16 or pad_length > len(data):
        return b""
    return data[:-pad_length]

def derive_key_and_iv(password):
    """Derive a key and IV from the given password using SHA-256"""
    key_hash = SHA256.new(password.encode()).digest()
    iv = bytes([key_hash[i * 2] ^ (4 * i + 1) for i in range(16)])
    return key_hash, iv

def aes_encrypt(plaintext, password):
    """Encrypt a plaintext string using AES-CBC"""
    key, iv = derive_key_and_iv(password)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    padded_data = pad(plaintext.encode())
    return cipher.encrypt(padded_data)

def aes_decrypt(ciphertext, password):
    """Decrypt an AES-CBC encrypted string"""
    key, iv = derive_key_and_iv(password)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    decrypted_padded = cipher.decrypt(ciphertext)
    return unpad(decrypted_padded).decode(errors="ignore")
