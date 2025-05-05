#pragma once

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
