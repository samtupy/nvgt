/* pack.h - legacy pack file implementation header
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

#include <angelscript.h>
#include <stdio.h>
#include <cstring>
#include <unordered_map>
#include <string>
#include <vector>
#include <Poco/BinaryReader.h>
#include <Poco/BinaryWriter.h>
#include <scriptarray.h>

typedef struct {
	unsigned int filesize; // Size of this file in unsigned chars.
	unsigned int namelen; // Length of this filename in unsigned chars.
	unsigned int magic; // whatever value results from the expression filesize*namelen*2, it doesn't matter if our unsigned int overflows because this is for verification and we don't care about the actual value.
	unsigned int offset; // Not actually saved in the final output stream, contains the true offset in the loaded binary file to this item's data.
} pack_item;

typedef struct {
	char ident[8];
	unsigned int filecount;
} pack_header;

typedef struct {
	std::string filename; // Filename associated with the stream, passed to pack::read_file.
	unsigned int offset; // Current offset in the stream.
	unsigned int filesize; // For convenience, only fetch it once and save it here.
	FILE* reader;
	bool reading;
	bool close;
	unsigned int stridx;
} pack_stream;

typedef enum { PACK_OPEN_MODE_NONE, PACK_OPEN_MODE_APPEND, PACK_OPEN_MODE_CREATE, PACK_OPEN_MODE_READ, PACK_OPEN_MODES_TOTAL } pack_open_mode;
class legacy_pack {
	FILE* fptr;
	unsigned char* mptr;
	std::unordered_map<std::string, pack_item> pack_items;
	std::vector<std::string> pack_filenames;
	std::unordered_map<unsigned int, pack_stream*>pack_streams;
	std::string current_filename;
	pack_open_mode open_mode;
	std::string pack_ident;
	unsigned int file_offset; // Offset into opened file where pack is contained, used for embedding packs into executables.
	int RefCount;
public:
	unsigned int next_stream_idx;
	bool delay_close;
	legacy_pack();
	void AddRef();
	void Release();
	bool set_pack_identifier(const std::string& ident);
	bool open(const std::string& filename, pack_open_mode mode, bool memload);
	bool close();
	bool add_file(const std::string& disk_filename, const std::string& pack_filename, bool allow_replace = false);
	bool add_memory(const std::string& pack_filename, unsigned char* data, unsigned int size, bool allow_replace = false);
	bool add_memory(const std::string& pack_filename, const std::string& data, bool allow_replace = false);
	bool delete_file(const std::string& pack_filename);
	bool file_exists(const std::string& pack_filename);
	unsigned int get_file_name(int idx, char* buffer, unsigned int size);
	std::string get_file_name(int idx);
	void list_files(std::vector<std::string>& files);
	CScriptArray* list_files();
	unsigned int get_file_size(const std::string& pack_filename);
	unsigned int get_file_offset(const std::string& pack_filename);
	unsigned int read_file(const std::string& pack_filename, unsigned int offset, unsigned char* buffer, unsigned int size, FILE* reader = NULL);
	std::string read_file_string(const std::string& pack_filename, unsigned int offset, unsigned int size);
	bool raw_seek(int offset);
	bool stream_close(pack_stream* stream, bool while_reading = false);
	pack_stream* stream_open(const std::string& pack_filename, unsigned int offset = 0);
	unsigned int stream_pos(pack_stream* stream) {
		return stream->offset;
	}
	unsigned int stream_read(pack_stream* stream, unsigned char* buffer, unsigned int size);
	bool stream_seek(pack_stream* stream, unsigned int offset, int origen = SEEK_SET);
	unsigned int stream_size(pack_stream* stream) {
		return stream->filesize;
	}
	bool stream_close_script(unsigned int idx);
	unsigned int stream_open_script(const std::string& pack_filename, unsigned int offset = 0);
	unsigned int stream_pos_script(unsigned int idx) {
		return pack_streams.find(idx) != pack_streams.end() ? pack_streams[idx]->offset : 0xffffffff;
	}
	unsigned int stream_read_script(unsigned int idx, unsigned char* buffer, unsigned int size);
	std::string stream_read_string(unsigned int idx, unsigned int size);
	bool stream_seek_script(unsigned int idx, unsigned int offset, int origen = SEEK_SET);
	unsigned int stream_size_script(unsigned int idx) {
		return pack_streams.find(idx) != pack_streams.end() ? pack_streams[idx]->filesize : 0;
	}
	unsigned int size() {
		return pack_items.size();
	}
	bool is_active() {
		return fptr || mptr;
	};
};

void RegisterScriptLegacyPack(asIScriptEngine* engine);
