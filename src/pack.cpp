/* pack.cpp - pack file implementation code
 * Class wsritten for NVGT by Caturria.
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

#include "pack.h"
#include <Poco/FileStream.h>
#include <Poco/StreamCopier.h>
#include <Poco/Util/Application.h> // config
#include <unordered_map> //For TOC in read mode.
#include <list>          //For TOC in write mode. Linearity is a hard requirement because it saves having to store an offset field in every TOC entry.
#include "hash.h"
#include <Poco/BinaryWriter.h>
#include <Poco/BinaryReader.h>
#include "misc_functions.h" // is_valid_utf8
#include <angelscript.h>
#include <Poco/Path.h>
#include <iostream>
#include "crypto.h" // chacha_stream
#include "datastreams.h"
#include <scriptarray.h>
#include "xplatform.h"

bool find_embedded_pack(std::string& filename, uint64_t& file_offset, uint64_t& file_size);
static const int header_size = 64;
static const uint32_t magic = 0xDadFaded;

struct pack::toc_entry {
	std::string filename; // Must be UTF-8.
	uint64_t offset; // We don't save this. In write mode, these are stored in a std::list, so we can take advantage of linearity to save space.
	uint64_t size;
};
typedef std::unordered_map<std::string, pack::toc_entry> toc_map;
typedef std::list<pack::toc_entry*> toc_list;
class pack::read_mode_internals {
	toc_map toc;
	std::istream* file;
	bool load();

public:
	uint64_t pack_offset; // Used for packs that are part of a larger file, needs to be accessed from the pack containing these internals when retrieving a file.
	uint64_t pack_size; // Used for packs that are part of a larger file.
	read_mode_internals(std::istream& file, const std::string& key = "", uint64_t pack_offset = 0, uint64_t pack_size = 0);
	~read_mode_internals();
	const toc_entry* get(const std::string& filename) const;
	bool exists(const std::string& filename);
	toc_map& get_toc_map(); // Used to implement at least get_file_count and list_files.
};
class pack::write_mode_internals {
	std::ostream* file;
	toc_map toc;
	toc_list ordered_toc; // Because we need to write the TOC entries in the same order as they were inserted.
	uint64_t data_size; // Tracked manually instead of relying on tellp(), which is needlessly hard to implement for custom ostreams.
	// Writes a block of zeros to the head of the file. Called once when a file is created. This header is updated when the file is finalized.
	bool put_blank_header();

public:
	// Writes the TOC and updates the header.
	bool finalize();

	// Pack itself is responsible for composing the stream it wants and passing it in. Internals take ownership though.
	write_mode_internals(std::ostream& file, const std::string& key = "");
	~write_mode_internals();
	const toc_entry* get(const std::string& filename) const;
	bool put(std::istream& in_file, const std::string& internal_name);
	bool exists(const std::string& filename);
	toc_map& get_toc_map(); // Used to implement at least get_file_count and list_files.
};
bool pack::read_mode_internals::load() {
	file->seekg(0, file->end);
	size_t file_size = file->tellg();
	file->seekg(0);
	if (!file->good()) {
		return false; // Unseekable stream presumably.
	}
	Poco::BinaryReader direct_reader(*file, Poco::BinaryReader::LITTLE_ENDIAN_BYTE_ORDER);
	Poco::BinaryReader* reader = &direct_reader; // Because BinaryReader deletes the assignment operator and we're going to swap underlying streams later.
	// File should begin with magic constant.
	uint32_t read_magic = 0;
	reader->readRaw((char*)&read_magic, 4);
	if (read_magic != magic)
		return false;
	uint64_t toc_offset;
	*reader >> toc_offset;
	if (toc_offset >= file_size || toc_offset < 64)
		return false;
	uint32_t checksum;
	*reader >> checksum;
	file->seekg(toc_offset);
	if (!file->good())
		return false;
	// We need to be computing the checksum while processing the TOC, so the binary reader is reconstructed to include the checksum node.
	checksum_istream check(*file);
	Poco::BinaryReader check_reader(check, Poco::BinaryReader::LITTLE_ENDIAN_BYTE_ORDER);
	reader = &check_reader;
	uint64_t current_offset = 64; // Just past the header.
	while (true) {
		toc_entry entry;
		uint64_t name_length = 0;
		reader->read7BitEncoded(name_length);
		// Don't get tricked into allocating a ridiculous amount of memory:
		if (name_length > 65535)
			return false;
		entry.filename.resize(name_length);
		reader->readRaw(&entry.filename[0], name_length);
		// Enforce the rules: file names must be UTF8 and may not contain characters in the non-printable ASCII ranges.
		if (!is_valid_utf8(entry.filename))
			return false;
		// And lastly, check that we aren't loading a duplicate:
		if (toc.find(entry.filename) != toc.end())
			return false;
		entry.offset = current_offset;
		// Because the checksum stream is in-between the source file and binary reader, we must perform goodness checks on the checksum stream, not directly on the file.
		if (!check.good())
			return false;
		reader->read7BitEncoded(entry.size);
		current_offset += entry.size;
		toc[entry.filename] = entry;
		// We may now be EOF, which indicates successful parsing of TOC.
		if (check.tellg() == file_size)
			break;
	}
	// Getting here means we ingested the TOC successfully. The last steps are to verify the checksum and to make sure the file offsets add up to the entire data block.
	if (check.get_checksum() != checksum)
		return false;
	if (current_offset != toc_offset)
		return false;
	return true;
}
pack::read_mode_internals::read_mode_internals(std::istream& file, const std::string& key, uint64_t pack_offset, uint64_t pack_size)
	: toc() {
	try {
		this->file = &file;
		if (pack_offset != 0 || pack_size != 0)
			this->file = new section_istream(*this->file, pack_offset, pack_size);
		if (!key.empty()) {
			chacha_istream* chacha = new chacha_istream(*this->file, key);
			chacha->own_source(true);
			this->file = chacha;
		}
		this->pack_offset = pack_offset;
		this->pack_size = pack_size;
		if (!load())
			throw std::runtime_error("Unable to load this pack file.");
	} catch (std::exception& e) {
		delete this->file;
		this->file = nullptr;
		throw e;
	}
}
pack::read_mode_internals::~read_mode_internals() {
	delete file;
}
const pack::toc_entry* pack::read_mode_internals::get(const std::string& filename) const {
	toc_map::const_iterator i = toc.find(filename);
	if (i == toc.end())
		return NULL;
	return &(i->second);
}
bool pack::read_mode_internals::exists(const std::string& filename) {
	return toc.find(filename) != toc.end();
}
toc_map& pack::read_mode_internals::get_toc_map() {
	return toc;
}
bool pack::write_mode_internals::put_blank_header() {
	if (!file->good())
		return false;
	char header[header_size];
	memset(header, 0, header_size);
	file->write(header, header_size);
	data_size = header_size;
	return true;
}
bool pack::write_mode_internals::finalize() {
	std::streampos toc_offset = data_size;
	if (!file->good())
		return false;
	// This ostream computes a checksum on incoming data and then passes it through to the attached sink.
	checksum_ostream check(*file);
	Poco::BinaryWriter writer(check, Poco::BinaryWriter::LITTLE_ENDIAN_BYTE_ORDER);
	for (toc_list::iterator i = ordered_toc.begin(); i != ordered_toc.end(); i++) {
		toc_entry& entry = **i;
		writer.write7BitEncoded(Poco::UInt32(entry.filename.length()));
		writer.writeRaw(entry.filename);
		writer.write7BitEncoded(entry.size);
	}
	writer.flush();
	// Capture the checksum at this point because we don't want to include the header in it.
	uint32_t checksum = check.get_checksum();
	// Now go back and update the header:
	file->seekp(0);
	writer.writeRaw((const char*)&magic, 4);
	writer << toc_offset;
	writer << checksum;
	writer.flush();
	return file->tellp() != -1;
}
pack::write_mode_internals::write_mode_internals(std::ostream& file, const std::string& key)
	: toc() {
	try {
		this->file = &file;
		if (!key.empty()) {
			chacha_ostream* chacha = new chacha_ostream(*this->file, key);
			chacha->own_sink(true);
			this->file = chacha;
		}
		if (!put_blank_header())
			throw std::runtime_error("Unable to write header to the file.");
	} catch (std::exception& e) {
		delete this->file;
		this->file = nullptr;
		throw e;
	}
}
pack::write_mode_internals::~write_mode_internals() {
	delete file;
}
const pack::toc_entry* pack::write_mode_internals::get(const std::string& filename) const {
	toc_map::const_iterator i = toc.find(filename);
	if (i == toc.end())
		return NULL;
	return &(i->second);
}
bool pack::write_mode_internals::put(std::istream& in_file, const std::string& internal_name) {
	try {
		if (toc.find(internal_name) != toc.end()) {
			return false; // Duplicate.
		}
		if (!is_valid_utf8(internal_name))
			return false;
		if (internal_name.length() > 65535)
			return false;
		toc_entry entry;
		entry.filename = internal_name;
		// We need to insert a copy of the TOC entry into the map, then insert a pointer to that into the list.
		toc_entry* inserted = &toc[internal_name];
		*inserted = entry;
		ordered_toc.push_back(inserted);
		std::streampos size = Poco::StreamCopier::copyStream(in_file, *file);
		inserted->size = size;
		data_size += size;
	} catch (std::exception&) {
		// Was the TOC entry already added?
		toc_map::iterator i = toc.find(internal_name);
		if (i != toc.end()) {
			// This is a file system error, out of disk space, etc. Throw here and don't bother trying to fix bookkeeping, because your pack is almost certainly corrupt at this point anyway.
			throw std::runtime_error("Critical error while writing data to pack.");
		}
		return false;
	}
	return true;
}
bool pack::write_mode_internals::exists(const std::string& filename) {
	return toc.find(filename) != toc.end();
}
toc_map& pack::write_mode_internals::get_toc_map() {
	return toc;
}
void pack::set_pack_name(const std::string& name) {
	pack_name = Poco::Path(name).absolute().toString();
}
pack::pack() : mutable_ptr(nullptr) {
	open_mode = OPEN_NOT;
}
pack::pack(const pack& other) : mutable_ptr(&other) {
	if (other.open_mode != OPEN_READ)
		throw std::invalid_argument("Only packs that are opened in read mode can be copy constructed. If you're trying to load sounds from a pack, please check the return value from your open call as your pack was not opened successfully.");
	open_mode = OPEN_READ;
	read = other.read;
	pack_name = other.pack_name;
	key = other.key;
	other.duplicate(); // We have no choice but to hold on to a reference to the pack we're cloning so that the user can safely query the pack in use.
}
pack::~pack() {
	if (mutable_ptr) mutable_ptr->release();
	close();
}
bool pack::create(const std::string& filename, const std::string& key) {
	close();
	Poco::FileOutputStream* file = NULL;
	try {
		file = new Poco::FileOutputStream(filename);
		write = std::make_shared<write_mode_internals>(*file, key);
	} catch (std::exception&) {
		// Don't delete here; internals may have chained several mutations onto the stream before it failed, so trust that it cleaned up.
		return false;
	}
	set_pack_name(filename);
	open_mode = OPEN_WRITE;
	return true;
}
bool pack::open(const std::string& filename, const std::string& key, uint64_t pack_offset, uint64_t pack_size) {
	close();
	std::string pack_filename = filename;
	if (!pack_size) find_embedded_pack(pack_filename, pack_offset, pack_size);
	Poco::FileInputStream* file = NULL;
	try {
		file = new Poco::FileInputStream(pack_filename);
		read = std::make_shared<read_mode_internals>(*file, key, pack_offset, pack_size);
	} catch (std::exception&) {
		// Don't delete here; internals may have chained several mutations onto the stream before it failed, so trust that it cleaned up.
		return false;
	}
	set_pack_name(pack_filename);
	this->key = key;
	open_mode = OPEN_READ;
	return true;
}
bool pack::close() {
	switch (open_mode) {
		case OPEN_NOT:
			return false;
		case OPEN_WRITE:
			write->finalize();
			write = nullptr;
			break;
		case OPEN_READ:
			read = nullptr;
			break;
	}
	open_mode = OPEN_NOT;
	return true;
}
bool pack::add_file(const std::string& filename, const std::string& internal_name) {
	if (open_mode != OPEN_WRITE)
		return false;
	try {
		Poco::FileInputStream fs(filename);
		return write->put(fs, internal_name);
	} catch (std::exception& e) { return false; }
}
bool pack::add_stream(const std::string& internal_name, datastream* ds) {
	if (open_mode != OPEN_WRITE || !ds || !ds->get_istr())
		return false;
	return write->put(*ds->get_istr(), internal_name);
}
bool pack::add_memory(const std::string& internal_name, const std::string& data) {
	if (open_mode != OPEN_WRITE)
		return false;
	Poco::MemoryInputStream ms(&data[0], data.size());
	return write->put(ms, internal_name);
}
bool pack::file_exists(const std::string& filename) {
	if (open_mode == OPEN_READ)
		return read->exists(filename);
	if (open_mode == OPEN_WRITE)
		return write->exists(filename);
	return false;
}
int64_t pack::get_file_size(const std::string& filename) {
	const toc_entry* e = open_mode == OPEN_READ ? read->get(filename) : write->get(filename);
	if (!e) return -1;
	return e->size;
}
std::istream* pack::get_file(const std::string& filename) const {
	if (open_mode != OPEN_READ)
		return nullptr;
	const toc_entry* entry = read->get(filename);
	if (entry == nullptr)
		return nullptr;
	std::istream* fis = nullptr;
	try {
		fis = new Poco::FileInputStream(pack_name, std::ios_base::in);
		if (read->pack_offset != 0 || read->pack_size != 0)
			fis = new section_istream(*fis, read->pack_offset, read->pack_size);
		if (!key.empty())
			fis = new chacha_istream(*fis, key);
		return new section_istream(*fis, entry->offset, entry->size);
	} catch (std::exception&) {
		delete fis;
		return nullptr;
	}
	return nullptr;
}
// Gets a file from the pack as a script compatible datastream. BGT-compatible interface that returns an inactive datastream if the file doesn't exist. To avoid header blote, this doesn't have its default arguments on the C++ side.
datastream* pack::get_file_script(const std::string& filename, const std::string& encoding, int byteorder) {
	std::istream* str = get_file(filename);
	if (str == nullptr)
		return new datastream();
	try {
		return new datastream(str, encoding, byteorder);
	} catch (const std::exception&) {
		// Expect this if script supplies bogus encoding or byteorder.
		delete str;
		return nullptr;
	}
}
bool pack::get_active() {
	return open_mode != OPEN_NOT;
}
int64_t pack::get_file_count() {
	if (open_mode == OPEN_NOT)
		return -1;
	return (open_mode == OPEN_READ ? read->get_toc_map() : write->get_toc_map()).size();
}
CScriptArray* pack::list_files() {
	asIScriptContext* context = asGetActiveContext();
	if (context == nullptr)
		return nullptr;
	asIScriptEngine* engine = context->GetEngine();
	if (engine == nullptr)
		return nullptr;
	asITypeInfo* string_array = engine->GetTypeInfoByDecl("string[]");
	if (string_array == nullptr)
		return nullptr;
	CScriptArray* array = CScriptArray::Create(string_array);
	if (array == nullptr)
		return nullptr;
	if (open_mode == OPEN_NOT)
		return array;
	toc_map& toc = (open_mode == OPEN_READ ? read->get_toc_map() : write->get_toc_map());
	array->Reserve(toc.size());
	for (toc_map::iterator i = toc.begin(); i != toc.end(); i++)
		array->InsertLast((void*)&i->first);
	return array;
}
bool pack::extract_file(const std::string& internal_name, const std::string& file_on_disk) {
	std::istream* fis = get_file(internal_name);
	if (fis == nullptr)
		return false;
	bool result = false;
	try {
		Poco::FileOutputStream fos(file_on_disk, std::ios_base::out);
		Poco::StreamCopier::copyStream(*fis, fos);
		result = true;
	} catch (std::exception&) {
		result = false;
	}
	delete fis;
	return result;
}

const std::string pack::get_pack_name() const {
	return pack_name;
}
void pack::release_pack(pack* obj) {
	obj->release();
}
std::shared_ptr<pack> pack::to_shared() {
	return std::make_shared<pack>(*this);
}
pack* pack::make() {
	return new pack();
}

/**
 * Section input stream.
 * This is an implementation of an istream that reads from a designated section of a source stream.
 * Stream positions and seek offsets are all relative to the beginning of the section.
 * This class is used by the pack class to return handles to individual files within the pack.
 * This stream takes ownership of its source stream and will delete it automatically.
*/
section_istreambuf::section_istreambuf(std::istream& source, std::streamoff start, std::streamsize size)
	: BasicBufferedStreamBuf(4096, std::ios_base::in) {
	this->source = &source;
	if (!source.good())
		throw std::invalid_argument("Stream is invalid.");
	source.seekg(start + size);
	if (source.tellg() != start + size)
		throw std::range_error("End is beyond end of file.");
	source.seekg(start);
	if (source.tellg() != start)
		throw std::runtime_error("Failed to seek to start offset.");
	this->start = start;
	this->size = size;
}
section_istreambuf::~section_istreambuf() {
	delete source;
}
int section_istreambuf::readFromDevice(char* buffer, std::streamsize length) {
	std::streampos pos = source->tellg();
	if (pos < start || pos >= start + size)
		return -1;
	length = std::min(length, std::streamsize(start + size - pos));
	source->read(buffer, length);
	return (int)length;
}
std::streampos section_istreambuf::seekoff(std::streamoff off, std::ios_base::seekdir dir, std::ios_base::openmode which) {
	source->clear();
	if (!source->good())
		return -1;
	switch (dir) {
		case std::ios_base::beg:
			return seekpos(off);
		case std::ios_base::end:
			return seekpos(size + off);
		case std::ios_base::cur:
			// Istream uses 0 cur to implement tell, so just report the current position without moving anything.
			if (off == 0)
				return source->tellg() - (std::streampos) start - (std::streampos) in_avail();
			return seekpos(source->tellg() - std::streampos(start - in_avail() + off));
	}
	return -1; // Can't get here.
}
std::streampos section_istreambuf::seekpos(std::streampos pos, std::ios_base::openmode which) {
	source->clear();
	if (!source->good())
		return -1;
	std::streampos true_pos = pos + start;
	if (true_pos > start + size)
		return -1;
	source->seekg(true_pos);
	this->setg(nullptr, nullptr, nullptr);
	return pos;
}

section_istream::section_istream(std::istream& source, std::streamoff start, std::streamsize size)
	: basic_istream(new section_istreambuf(source, start, size)) {
}
section_istream::~section_istream() {
	delete rdbuf();
}

struct embedded_pack { uint64_t offset; uint64_t size; };
std::unordered_map<std::string, std::string> embedding_packs; // embed_filename:disc_filename
std::unordered_map<std::string, embedded_pack> embedded_packs; // embed_filename:embed_offset/size
void embed_pack(const std::string& disc_filename, const std::string& embed_filename) {
	if (embedding_packs.find(embed_filename) != embedding_packs.end()) return;
	embedding_packs[embed_filename] = disc_filename;
}
bool load_embedded_packs(Poco::BinaryReader& br) {
	unsigned int total;
	br.read7BitEncoded(total);
	for (unsigned int i = 0; i < total; i++) {
		std::string name;
		br >> name;
		unsigned int size;
		br >> size;
		embedded_packs[name] = embedded_pack {uint64_t(br.stream().tellg()), size};
		br.stream().seekg(size, std::ios::cur);
	}
	return true;
}
void write_embedded_packs(Poco::BinaryWriter& bw) {
	bw.write7BitEncoded(uint32_t(embedding_packs.size()));
	for (const auto& p : embedding_packs) {
		bw << p.first;
		Poco::FileInputStream fs(p.second);
		bw << uint32_t(fs.size());
		Poco::StreamCopier::copyStream(fs, bw.stream());
		fs.close();
	}
}
bool find_embedded_pack(std::string& filename, uint64_t& file_offset, uint64_t& file_size) {
	// Translate values that exist as part of a pack::open call so that an embedded pack will be loaded if required.
	if (filename.empty() || filename[0] != '*') return false;
	#ifndef NVGT_STUB
	// If running from nvgt's compiler the packs are not actually embedded, translate the user input back to a valid filename.
	if (filename == "*" && embedding_packs.size() > 0) filename = embedding_packs.begin()->second; // BGT compatibility
	else filename = embedding_packs[filename.substr(1)];
	return true;
	#else
	const auto& it = filename == "*" ? embedded_packs.begin() : embedded_packs.find(filename.substr(1));
	if (it == embedded_packs.end()) return false;
	#ifndef __ANDROID__
	filename = Poco::Util::Application::instance().config().getString("application.path");
	#else
	filename = android_get_main_shared_object();
	#endif
	file_offset = it->second.offset;
	file_size = it->second.size;
	return true;
	#endif
	return false;
}

void RegisterScriptPack(asIScriptEngine* engine) {
	engine->RegisterObjectBehaviour("pack_interface", asBEHAVE_ADDREF, "void b()", asMETHOD(pack_interface, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pack_interface", asBEHAVE_RELEASE, "void c()", asMETHOD(pack_interface, release), asCALL_THISCALL);
	engine->RegisterObjectType("pack_file", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("pack_file", asBEHAVE_FACTORY, "pack_file@ a()", asFUNCTION(pack::make), asCALL_CDECL);
	engine->RegisterObjectBehaviour("pack_file", asBEHAVE_ADDREF, "void b()", asMETHODPR(pack, duplicate, () const, void), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("pack_file", asBEHAVE_RELEASE, "void c()", asMETHODPR(pack, release, () const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "pack_interface@ opImplCast()", asFUNCTION((pack_interface::op_cast<pack, pack_interface>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("pack_interface", "pack_file@ opCast()", asFUNCTION((pack_interface::op_cast<pack_interface, pack>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("pack_file", "bool create(const string &in filename, const string&in key = \"\")", asMETHOD(pack, create), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool open(const string &in filename, const string &in key = \"\", uint64 pack_offset = 0, uint64 pack_size = 0)", asMETHOD(pack, open), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool close()", asMETHOD(pack, close), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool add_file(const string &in filename, const string &in internal_name)", asMETHOD(pack, add_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool add_stream(const string &in internal_name, datastream@ ds)", asMETHOD(pack, add_stream), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool add_memory(const string &in internal_name, const string&in data)", asMETHOD(pack, add_memory), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool file_exists(const string &in filename)", asMETHOD(pack, file_exists), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "int64 get_file_size(const string &in filename)", asMETHOD(pack, get_file_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "datastream @get_file(const string &in filename, const string &in encoding = \"\", int byteorder = STREAM_BYTE_ORDER_NATIVE)", asMETHOD(pack, get_file_script), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "string get_pack_name() const property", asMETHOD(pack, get_pack_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool get_active() const property", asMETHOD(pack, get_active), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "int64 get_file_count() const property", asMETHOD(pack, get_file_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "string[]@ list_files() const", asMETHOD(pack, list_files), asCALL_THISCALL);
	engine->RegisterObjectMethod("pack_file", "bool extract_file(const string &in internal_name, const string &in file_on_disk)", asMETHOD(pack, extract_file), asCALL_THISCALL);
}
