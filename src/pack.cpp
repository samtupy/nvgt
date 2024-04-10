/* pack.cpp - pack file implementation code
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

#include <errno.h>
#include <obfuscate.h>
#ifndef _WIN32
	#include <sys/stat.h>
	#include <unistd.h>
#else
	#include <windows.h>
	#include <io.h>
#endif
#include "filesystem.h"
#ifndef NVGT_USER_CONFIG // pack_char_encrypt/decrypt
	#include "nvgt_config.h"
#else
	#include "../user/nvgt_config.h"
#endif
#include "pack.h"

using namespace std;

// A global property that allows a scripter to set the pack identifier for all subsequently created packs.
static std::string g_pack_ident = "NVPK";

pack::pack() {
	fptr = NULL;
	mptr = NULL;
	pack_items.clear();
	pack_filenames.clear();
	pack_streams.clear();
	current_filename = "";
	set_pack_identifier(g_pack_ident);
	next_stream_idx = 0;
	open_mode = PACK_OPEN_MODE_NONE;
	delay_close = false;
	RefCount = 1;
}
void pack::AddRef() {
	asAtomicInc(RefCount);
}
void pack::Release() {
	if (asAtomicDec(RefCount) < 1)
		delete this;
}

// Sets the 8 byte header used when loading and saving packs.
bool pack::set_pack_identifier(const std::string& ident) {
	if (ident == "") return false;
	pack_ident = ident;
	if (pack_ident.size() > 8) pack_ident.resize(8);
	while (pack_ident.size() < 8) pack_ident += '\0';
	return true;
}
// Loads or creates the given pack file based on mode.
bool pack::open(const string& filename, pack_open_mode mode, bool memload) {
	if (fptr || mptr)
		return false; // This object is already in use and must be closed first.
	if (mode <= PACK_OPEN_MODE_NONE || mode >= PACK_OPEN_MODES_TOTAL)
		return false; // Invalid mode.
	if (mode == PACK_OPEN_MODE_APPEND && !FileExists(filename))
		mode = PACK_OPEN_MODE_CREATE;
	if (mode == PACK_OPEN_MODE_CREATE) {
		#ifndef _UNICODE
		fptr = fopen(filename.c_str(), "wb");
		#else
		fptr = _wfopen(filename.c_str(), L"wb");
		#endif
		if (fptr == NULL)
			return false;
		pack_header h;
		memset(&h, 0, sizeof(pack_header));
		memcpy(&h, &pack_ident[0], 8);
		h.filecount = 0;
		fwrite(&h, sizeof(pack_header), 1, fptr);
		current_filename = filename;
		open_mode = mode;
		return true;
	} else if (mode == PACK_OPEN_MODE_APPEND || mode == PACK_OPEN_MODE_READ) {
		#ifndef _UNICODE
		fptr = fopen(filename.c_str(), mode == PACK_OPEN_MODE_APPEND ? "rb+" : "rb");
		#else
		fptr = _wfopen(filename.c_str(), mode == PACK_OPEN_MODE_APPEND ? L"rb+" : L"rb");
		#endif
		if (!fptr)
			return false;
		#ifdef _WIN32
		unsigned int total_size = filelength(fileno(fptr));
		#else
		struct stat st;
		unsigned int total_size = 0;
		if (fstat(fileno(fptr), &st) == 0)
			total_size = st.st_size;
		#endif
		fseek(fptr, 0, SEEK_SET);
		pack_header h;
		if (!fread(&h, sizeof(pack_header), 1, fptr)) {
			fclose(fptr);
			return false;
		}
		if (memcmp(h.ident, &pack_ident[0], 8) != 0) {
			fclose(fptr);
			return false;
		}
		for (unsigned int c = 0; c < h.filecount; c++) {
			unsigned int current_pos = ftell(fptr);
			pack_item i;
			memset(&i, 0, sizeof(pack_item));
			if (fread(&i, sizeof(unsigned int), 3, fptr) < 3) {
				pack_items.clear();
				pack_filenames.clear();
				fclose(fptr);
				return false;
			}
			string fn(i.namelen, '\0');
			if ((i.filesize * i.namelen * 2) != i.magic || i.namelen > total_size || i.filesize > total_size || fread(&fn[0], 1, i.namelen, fptr) < i.namelen) {
				pack_items.clear();
				pack_filenames.clear();
				fclose(fptr);
				return false;
			}
			i.offset = ftell(fptr);
			pack_items[fn] = i;
			pack_filenames.push_back(fn);
			fseek(fptr, i.filesize, SEEK_CUR);
		}
		// Perform any extra read/append initialization
		if (mode == PACK_OPEN_MODE_READ && memload) {
			mptr = (unsigned char*)malloc(total_size);
			FILE* mtmp;
			#ifndef _UNICODE
			mtmp = fopen(filename.c_str(), "rb+");
			#else
			mtmp = _wfopen(filename.c_str(), L"rb+");
			#endif
			if (mtmp && mptr) {
				fread(mptr, 1, total_size, mtmp);
				fclose(mtmp);
			} else {
				free(mptr);
				mptr = NULL;
			}
		}
	}
	current_filename = filename;
	open_mode = mode;
	return true;
}

bool pack::close() {
	while (delay_close) Sleep(5);
	delay_close = false;
	bool was_opened = fptr || mptr;
	bool ret = false;
	if (fptr && (open_mode == PACK_OPEN_MODE_APPEND || open_mode == PACK_OPEN_MODE_CREATE)) {
		pack_header h;
		memset(&h, 0, sizeof(pack_header));
		memcpy(h.ident, &pack_ident[0], 8);
		h.filecount = pack_items.size();
		fseek(fptr, 0, SEEK_SET);
		ret = fwrite(&h, sizeof(pack_header), 1, fptr) == 1;
	} else
		ret = true;
	if (fptr)
		fclose(fptr);
	pack_items.clear();
	pack_filenames.clear();
	pack_streams.clear();
	current_filename = "";
	//next_stream_idx=0;
	open_mode = PACK_OPEN_MODE_NONE;
	fptr = NULL;
	if (mptr)
		free(mptr);
	mptr = NULL;
	return ret;
}

// Adds a file from disk to the pack. Returns false if disk filename doesn't exist or can't be read, pack_filename is already an item in the pack and allow_replace is false, or this object is not opened in append/create mode.
bool pack::add_file(const string& disk_filename, const string& pack_filename, bool allow_replace) {
	if (!fptr)
		return false;
	if (open_mode != PACK_OPEN_MODE_APPEND && open_mode != PACK_OPEN_MODE_CREATE)
		return false;
	if (!FileExists(disk_filename))
		return false;
	if (file_exists(pack_filename)) {
		if (allow_replace)
			delete_file(pack_filename);
		else
			return false;
	}
	#ifdef _UNICODE
	FILE* dptr = _wfopen(disk_filename.c_str(), L"rb");
	#else
	FILE* dptr = fopen(disk_filename.c_str(), "rb");
	#endif
	if (!dptr)
		return false;
	unsigned int cur_pos = ftell(fptr);
	pack_item i;
	memset(&i, 0, sizeof(pack_item));
	i.namelen = pack_filename.size();
	i.offset = cur_pos + i.namelen + (sizeof(unsigned int) * 3);
	if (fwrite(&i, sizeof(unsigned int), 3, fptr) < 3) {
		fseek(fptr, cur_pos, SEEK_SET);
		fclose(dptr);
		return false;
	}
	#ifdef _UNICODE
	char* filenameA = (char*)malloc(i.namelen + 1);
	WideCharToMultiunsigned char(CP_ACP, 0, pack_filename.c_str(), i.namelen, filenameA, i.namelen + 1, NULL, NULL);
	if (fwrite(filenameA, sizeof(char), i.namelen, fptr) < i.namelen) {
		free(filenameA);
		fseek(fptr, cur_pos, SEEK_SET);
		fclose(dptr);
		return false;
	}
	free(filenameA);
	#else
	if (fwrite(pack_filename.c_str(), sizeof(char), i.namelen, fptr) < i.namelen) {
		fseek(fptr, cur_pos, SEEK_SET);
		fclose(dptr);
		return false;
	}
	#endif
	unsigned char read_buffer[4096];
	while (true) {
		unsigned int dataread = fread(read_buffer, 1, 4096, dptr);
		if (dataread < 1)
			break;
		for (unsigned int j = 0; j < dataread; j++)
			read_buffer[j] = pack_char_encrypt(read_buffer[j], i.filesize + j, i.namelen);
		fwrite(read_buffer, 1, dataread, fptr);
		i.filesize += dataread;
		if (dataread < 4096)
			break;
	}
	fclose(dptr);
	fseek(fptr, cur_pos, SEEK_SET);
	i.magic = i.filesize * i.namelen * 2;
	if (fwrite(&i, sizeof(unsigned int), 3, fptr) < 3) {
		fseek(fptr, cur_pos, SEEK_SET);
		fclose(dptr);
		return false;
	}
	fseek(fptr, 0, SEEK_END);
	pack_items[pack_filename] = i;
	pack_filenames.push_back(pack_filename);
	return true;
}

bool pack::add_memory(const string& pack_filename, unsigned char* data, unsigned int size, bool allow_replace) {
	if (open_mode != PACK_OPEN_MODE_APPEND && open_mode != PACK_OPEN_MODE_CREATE || !fptr)
		return false;
	if (file_exists(pack_filename)) {
		if (allow_replace)
			delete_file(pack_filename);
		else
			return false;
	}
	unsigned int cur_pos = ftell(fptr);
	pack_item i;
	memset(&i, 0, sizeof(pack_item));
	i.filesize = size;
	i.namelen = pack_filename.size();
	i.magic = i.filesize * i.namelen * 2;
	i.offset = cur_pos + i.namelen + (sizeof(unsigned int) * 3);
	if (fwrite(&i, sizeof(unsigned int), 3, fptr) < 3) {
		fseek(fptr, cur_pos, SEEK_SET);
		return false;
	}
	#ifdef _UNICODE
	char* filenameA = (char*)malloc(i.namelen + 1);
	WideCharToMultiunsigned char(CP_ACP, 0, pack_filename.c_str(), i.namelen, filenameA, i.namelen + 1, NULL, NULL);
	if (fwrite(filenameA, sizeof(char), i.namelen, fptr) < i.namelen) {
		free(filenameA);
		fseek(fptr, cur_pos, SEEK_SET);
		return false;
	}
	free(filenameA);
	#else
	if (fwrite(pack_filename.c_str(), sizeof(char), i.namelen, fptr) < i.namelen) {
		fseek(fptr, cur_pos, SEEK_SET);
		return false;
	}
	#endif
	for (unsigned int j = 0; j < size; j++)
		data[j] = pack_char_encrypt(data[j], j, i.namelen);
	if (fwrite(data, 1, size, fptr) != size) {
		fseek(fptr, cur_pos, SEEK_SET);
		return false;
	}
	pack_items[pack_filename] = i;
	pack_filenames.push_back(pack_filename);
	return true;
}
// Adds memory, but getting data from a C++ string.
bool pack::add_memory(const string& pack_filename, const std::string& data, bool allow_replace) {
	return add_memory(pack_filename, (unsigned char*)data.c_str(), data.size(), allow_replace);
}

// Deletes a file from the pack if it exists, and returns true on success. This operation is usually highly intensive, and if you must do it over and over again, it's best to just recompile your pack. If this function returns false, and you are sure your arguments are correct, you can consider that your pack file is now probably corrupt. This should only happen if the pack contains invalid headers or incomplete file data in the first place.
bool pack::delete_file(const string& pack_filename) {
	if (open_mode != PACK_OPEN_MODE_APPEND && open_mode != PACK_OPEN_MODE_CREATE || !fptr)
		return false;
	unsigned int idx = 0;
	for (idx = 0; idx < pack_filenames.size(); idx++) {
		if (pack_filenames[idx] == pack_filename)
			break;
	}
	if (idx >= pack_filenames.size())
		return false;
	unsigned int oldsize = pack_items[pack_filename].filesize;
	unsigned int oldblock = pack_items[pack_filename].namelen + pack_items[pack_filename].filesize + (sizeof(unsigned int) * 3);
	unsigned int oldnlen = pack_items[pack_filename].namelen;
	unsigned int oldoff = pack_items[pack_filename].offset;
	pack_items.erase(pack_filename);
	pack_filenames.erase(pack_filenames.begin() + idx);
	unsigned char tmp[4096];
	unsigned int new_eof = oldoff - oldnlen - (sizeof(unsigned int) * 3);
	for (unsigned int i = idx; i < pack_filenames.size(); i++) {
		pack_item item = pack_items[pack_filenames[i]];
		unsigned int total_bytesread = 0;
		while (total_bytesread < item.filesize) {
			fseek(fptr, item.offset + total_bytesread, SEEK_SET);
			unsigned int bytes_to_read = 4096;
			if (item.filesize - total_bytesread < 4096)
				bytes_to_read = item.filesize - total_bytesread;
			unsigned int bytesread = fread(tmp, sizeof(unsigned char), bytes_to_read, fptr);
			if (bytesread < bytes_to_read)
				return false; // something went really wrong!
			fseek(fptr, item.offset + total_bytesread - oldblock, SEEK_SET);
			fwrite(tmp, sizeof(unsigned char), bytesread, fptr);
			total_bytesread += bytesread;
		}
		new_eof = ftell(fptr);
		pack_items[pack_filenames[i]].offset -= oldblock;
		item.offset -= oldblock;
		fseek(fptr, item.offset - item.namelen - (sizeof(unsigned int) * 3), SEEK_SET);
		fwrite(&item, sizeof(unsigned int), 3, fptr);
		fwrite(pack_filenames[i].c_str(), 1, item.namelen, fptr);
		char tmp_idx[3];
		//new_eof+=total_bytesread+item.namelen+(sizeof(unsigned int)*3);
	}
	// This sucks...
	//new_eof-=oldblock-oldsize;
	#ifdef _WIN32
	HANDLE hFile = CreateFile(current_filename.c_str(), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (!hFile)
		return true; // At this point the operation has completed, but we couldn't set the new eof. Hopefully a new file being added to the pack gets a chance to overwrite the new existing deleted data...
	SetFilePointer(hFile, new_eof, NULL, FILE_BEGIN);
	SetEndOfFile(hFile);
	CloseHandle(hFile);
	fclose(fptr);
	#ifndef _UNICODE
	fptr = fopen(current_filename.c_str(), "rb+");
	#else
	fptr = _wfopen(current_filename.c_str(), L"rb+");
	#endif
	if (!fptr) {
		close(); // We couldn't reopen the file after delete, and so we must entirely close the pack in this unfortunate case.
		return false;
	}
	#else
	ftruncate(fileno(fptr), new_eof);
	#endif
	fseek(fptr, 0, SEEK_END);
	return true;
}

bool pack::file_exists(const string& pack_filename) {
	return pack_items.find(pack_filename) != pack_items.end();
}

unsigned int pack::get_file_name(int idx, TCHAR* buffer, unsigned int size) {
	if (idx < 0 || idx >= pack_filenames.size())
		return 0;
	if (!buffer || size <= pack_filenames[idx].size())
		return pack_filenames[idx].size() + 1;
	size = pack_filenames[idx].size();
	#ifdef _UNICODE
	wcsncpy(buffer, pack_filenames[idx].c_str(), size);
	buffer[size] = L'\0';
	#else
	strncpy(buffer, pack_filenames[idx].c_str(), size);
	buffer[size] = '\0';
	#endif
	return size;
}
string pack::get_file_name(int idx) {
	if (idx < 0 || idx >= pack_filenames.size())
		return 0;
	return pack_filenames[idx];
}
CScriptArray* pack::list_files() {
	unsigned int count = pack_filenames.size();
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType);
	array->Reserve(count);
	for (int i = 0; i < count; i++)
		array->InsertLast(&pack_filenames[i]);
	return array;
}

unsigned int pack::get_file_size(const string& pack_filename) {
	if (pack_items.find(pack_filename) != pack_items.end())
		return pack_items[pack_filename].filesize;
	else
		return 0;
}

unsigned int pack::get_file_offset(const string& pack_filename) {
	if (pack_items.find(pack_filename) != pack_items.end())
		return pack_items[pack_filename].offset;
	else
		return 0;
}

unsigned int pack::read_file(const string& pack_filename, unsigned int offset, unsigned char* buffer, unsigned int size, FILE* reader) {
	if (pack_items.find(pack_filename) == pack_items.end()) return 0;
	unsigned int item_size = pack_items[pack_filename].filesize;
	if (offset >= item_size)
		return 0;
	unsigned int bytes_to_read = size;
	if (offset + size > item_size)
		bytes_to_read = item_size - offset;
	if (!buffer)
		return bytes_to_read;
	if (open_mode == PACK_OPEN_MODE_READ && mptr) {
		memcpy(buffer, mptr + pack_items[pack_filename].offset + offset, bytes_to_read);
		for (unsigned int i = 0; i < bytes_to_read; i++)
			buffer[i] = pack_char_decrypt(buffer[i], offset + i, pack_items[pack_filename].namelen);
		return bytes_to_read;
	}
	if (!reader)
		reader = fptr;
	if (open_mode != PACK_OPEN_MODE_READ || !reader || pack_items.find(pack_filename) == pack_items.end())
		return 0;
	fseek(reader, pack_items[pack_filename].offset + offset, SEEK_SET);
	unsigned int dataread = fread(buffer, 1, bytes_to_read, reader);
	for (unsigned int i = 0; i < dataread; i++)
		buffer[i] = pack_char_decrypt(buffer[i], offset + i, pack_items[pack_filename].namelen);
	return dataread;
}
std::string pack::read_file_string(const string& pack_filename, unsigned int offset, unsigned int size) {
	std::string result(size, '\0');
	int actual_size = read_file(pack_filename, offset, (unsigned char*)&result.front(), size);
	if (actual_size > -1)
		result.resize(actual_size);
	return result;
}

// Function to force the file pointer for the open pack to seek by a relative position either from the beginning or the end of the file. This function should only be used if you are absolutely sure you know what you are doing, incorrect usage will lead to corrupt packs. If offset is negative, seek from the end, else from the beginning.
bool pack::raw_seek(int offset) {
	if (!fptr)
		return false;
	if (offset < 0)
		return fseek(fptr, offset, SEEK_END) == 0;
	else
		return fseek(fptr, offset, SEEK_SET);
}

// Closes an opened stream, basically freeing it's structure of data.
bool pack::stream_close(pack_stream* stream, bool while_reading) {
	if (stream->reading) {
		stream->close = true;
		pack_streams.find(stream->stridx) != pack_streams.end()&&pack_streams.erase(stream->stridx);
		return true;
	}
	bool ret = !while_reading & pack_streams.find(stream->stridx) != pack_streams.end() && pack_streams.erase(stream->stridx);
	stream->stridx = 0;
	if (stream->reader)
		fclose(stream->reader);
	delete stream;
	Release();
	return ret;
}
bool pack::stream_close_script(unsigned int idx) {
	if (pack_streams.find(idx) == pack_streams.end())
		return false;
	return stream_close(pack_streams[idx]);
}

// Creates a pack_stream structure for the given filename at the given offset. Pack streams are simple structures meant to expidite the process of sequentially reading from a file in the pack. Returns 0xffffffff on failure.
pack_stream* pack::stream_open(const string& pack_filename, unsigned int offset) {
	if (pack_filename == "")
		return NULL;
	if (pack_items.find(pack_filename) == pack_items.end())
		return NULL;
	unsigned int size = pack_items[pack_filename].filesize;
	pack_stream* s = new pack_stream();
	s->filename = pack_filename;
	s->offset = offset;
	s->filesize = size;
	s->reading = false;
	s->close = false;
	if (!mptr) {
		#ifndef _UNICODE
		s->reader = fopen(current_filename.c_str(), "rb");
		#else
		s->reader = _wfopen(current_filename.c_str(), L"rb");
		#endif
		if (!s->reader)
			return NULL;
	} else
		s->reader = NULL;
	pack_streams[next_stream_idx] = s;
	s->stridx = next_stream_idx;
	next_stream_idx += 1;
	AddRef();
	return s;
}
unsigned int pack::stream_open_script(const string& pack_filename, unsigned int offset) {
	pack_stream* stream = stream_open(pack_filename, offset);
	if (stream) return stream->stridx;
	else return 0xffffffff;
}

// Reads bytes from a stream and increments it's offset by the number of bytes read. Returns the number of bytes read on success, 0xffffffff (-1) on failure either do to end of file or invalid stream.
unsigned int pack::stream_read(pack_stream* stream, unsigned char* buffer, unsigned int size) {
	stream->reading = true;
	unsigned int bytesread = read_file(stream->filename.c_str(), stream->offset, buffer, size, stream->reader);
	stream->reading = false;
	bool close = stream->close;
	if (stream->close)
		stream_close(stream);
	if (bytesread == 0xffffffff)
		return 0xffffffff;
	if (!close)
		stream->offset += bytesread;
	return bytesread;
}
unsigned int pack::stream_read_script(unsigned int idx, unsigned char* buffer, unsigned int size) {
	if (pack_streams.find(idx) == pack_streams.end())
		return 0xffffffff;
	return stream_read(pack_streams[idx], buffer, size);
}
std::string pack::stream_read_string(unsigned int idx, unsigned int size) {
	std::string result(size, '\0');
	int actual_size = stream_read_script(idx, (unsigned char*)&result.front(), size);
	if (actual_size > -1)
		result.resize(size);
	return result;
}

// Seeks within a stream. We're using the exact same argument convention actually as fseek here, origin means the same thing. In this case though, we return true on success, not 0.
bool pack::stream_seek(pack_stream* stream, unsigned int offset, int origin) {
	if (origin == SEEK_SET && offset < stream->filesize)
		stream->offset = offset;
	else if (origin == SEEK_CUR && stream->offset + offset >= 0 && stream->offset + offset < stream->filesize)
		stream->offset += offset;
	else if (origin == SEEK_END && offset < 0 && offset >= -stream->filesize)
		stream->offset = stream->filesize + offset;
	else
		return false;
	if (!mptr && stream->reader)
		fseek(stream->reader, stream->offset, SEEK_SET);
	return true;
}
bool pack::stream_seek_script(unsigned int idx, unsigned int offset, int origin) {
	if (pack_streams.find(idx) == pack_streams.end())
		return false;
	return stream_seek(pack_streams[idx], offset, origin);
}

bool pack_set_global_identifier(const std::string& identifier) {
	if (identifier == "") return false;
	g_pack_ident = identifier;
	return true; // Further validation will be performed in pack::set_pack_identifier.
}

pack* ScriptPack_Factory() {
	return new pack();
}
int packmode1 = PACK_OPEN_MODE_NONE, packmode2 = PACK_OPEN_MODE_APPEND, packmode3 = PACK_OPEN_MODE_CREATE, packmode4 = PACK_OPEN_MODE_READ;
void RegisterScriptPack(asIScriptEngine* engine) {
	engine->RegisterGlobalProperty(_O("const int PACK_OPEN_MODE_NONE"), &packmode1);
	engine->RegisterGlobalProperty(_O("const int PACK_OPEN_MODE_APPEND"), &packmode2);
	engine->RegisterGlobalProperty(_O("const int PACK_OPEN_MODE_CREATE"), &packmode3);
	engine->RegisterGlobalProperty(_O("const int PACK_OPEN_MODE_READ"), &packmode4);
	engine->RegisterGlobalProperty(_O("const string pack_global_identifier"), &g_pack_ident);
	engine->RegisterGlobalFunction(_O("bool pack_set_global_identifier(const string&in)"), asFUNCTION(pack_set_global_identifier), asCALL_CDECL);
	engine->RegisterObjectType(_O("pack"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("pack"), asBEHAVE_FACTORY, _O("pack @p()"), asFUNCTION(ScriptPack_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("pack"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(pack, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("pack"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(pack, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool set_pack_identifier(const string&in)"), asMETHOD(pack, set_pack_identifier), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool open(const string &in, uint, bool = false)"), asMETHOD(pack, open), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool close()"), asMETHOD(pack, close), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool add_file(const string &in, const string& in, bool = false)"), asMETHOD(pack, add_file), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool add_memory(const string &in, const string& in, bool = false)"), asMETHODPR(pack, add_memory, (const string&, const string&, bool), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool delete_file(const string &in)"), asMETHOD(pack, delete_file), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool file_exists(const string &in) const"), asMETHOD(pack, file_exists), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("string get_file_name(int) const"), asMETHODPR(pack, get_file_name, (int), string), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("string[]@ list_files() const"), asMETHODPR(pack, list_files, (), CScriptArray*), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint get_file_size(const string &in) const"), asMETHOD(pack, get_file_size), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint get_file_offset(const string &in) const"), asMETHOD(pack, get_file_offset), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("string read_file(const string &in, uint, uint) const"), asMETHOD(pack, read_file_string), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool raw_seek(int)"), asMETHOD(pack, raw_seek), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool stream_close(uint)"), asMETHOD(pack, stream_close_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint stream_open(const string &in, uint) const"), asMETHOD(pack, stream_open_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("string stream_read(uint, uint) const"), asMETHOD(pack, stream_read), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint stream_pos(uint) const"), asMETHOD(pack, stream_pos_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint stream_seek(uint, uint, int) const"), asMETHOD(pack, stream_seek_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint stream_size(uint) const"), asMETHOD(pack, stream_size_script), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("bool get_active() const property"), asMETHOD(pack, is_active), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("pack"), _O("uint get_size() const property"), asMETHOD(pack, size), asCALL_THISCALL);
}
