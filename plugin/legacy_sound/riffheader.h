/* riffheader.h - rough and simple creation of wav headers
 * A tiny single file header I threw together from existing code that majorly assists in writing wav files by generating the first 44 bytes, the RIFF header. All data after that is up to the implementing code.
 * We currently trust that a wav_header structure can be written verbatim to a wav file, this may need updating on platforms that have different byte endianness / structural alignment settings.
 * To use, #define riffheader_impl in one c/c++ unit before including riffheader.h.
 * wav_header make_wav_header(DWORD filesize=0, DWORD samprate=44100, DWORD bitrate=16, short channels=2, short format=1)
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
#include <cstring>

// The below structure has been slightly modified from https://gist.github.com/Jon-Schneider/8b7c53d27a7a13346a643dac9c19d34f
// This structure should not be used to examine existing wav files, but instead just to write new ones. This is because many existing wav files will contain metadata chunks or other information that this structure cannot handle.
typedef struct {
	char riff_header[4]; // Contains "RIFF"
	unsigned int wav_size; // Size of the wav portion of the file, which follows the first 8 bytes. File size - 8
	char wave_header[4]; // Contains "WAVE"
	char fmt_header[4]; // Contains "fmt " (includes trailing space)
	int fmt_chunk_size; // Should be 16 for PCM
	short audio_format; // Should be 1 for PCM. 3 for IEEE Float
	short num_channels;
	int sample_rate;
	unsigned int byte_rate; // Number of bytes per second. sample_rate * num_channels * Bytes Per Sample
	short sample_alignment; // num_channels * Bytes Per Sample
	short bit_depth; // Number of bits per sample
	char data_header[4]; // Contains "data"
	unsigned int data_bytes; // Number of bytes in data. Number of samples * num_channels * sample byte size
} wav_header;

wav_header make_wav_header(unsigned int filesize = 0, unsigned int samprate = 44100, unsigned int bitrate = 16, short channels = 2, short format = 1);

#ifdef riffheader_impl
// This function fills a wav_header structure with data and returns it. Please remember that the arguments passed to this function are *EXPECTED! to be correct, no verification is performed. So if you set your bitrate to something other than a multiple of 8, for example, this function's return value is then officially undefined.
#ifdef __CPLUSPLUS
extern "C" {
#endif
	wav_header make_wav_header(unsigned int filesize, unsigned int samprate, unsigned int bitrate, short channels, short format) {
		const char* riff = "RIFF";
		const char* wavefmt = "WAVEfmt ";
		const char* data = "data";
		wav_header h;
		std::memset(&h, 0, sizeof(wav_header));
		std::strncpy(h.riff_header, riff, 4);
		if (filesize > 0)
			h.wav_size = filesize - 8;
		else
			h.wav_size = 0;
		std::memcpy(h.wave_header, wavefmt, 8);
		h.fmt_chunk_size = 16;
		h.audio_format = format;
		h.num_channels = channels;
		h.sample_rate = samprate;
		h.byte_rate = samprate * channels * (bitrate / 8);
		h.sample_alignment = channels * (bitrate / 8);
		h.bit_depth = bitrate;
		std::strncpy(h.data_header, data, 4);
		if (filesize > 0)
			h.data_bytes = filesize - sizeof(wav_header);
		else
			h.data_bytes = 0;
		return h;
	}
	#ifdef __CPLUSPLUS
}
	#endif
#endif
