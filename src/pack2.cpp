/* pack.cpp - pack file implementation code
 * Note: temporarily namespaced as new_packto avoid name collision problems on the C++ side during integration: will be changed once the original packfile is removed.
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
#include "pack2.h"
#include <Poco/FileStream.h>
#include <Poco/StreamCopier.h>
#include <unordered_map> //For TOC in read mode.
#include <list>			 //For TOC in write mode. Linearity is a hard requirement because it saves having to store an offset field in every TOC entry.
#include "checksum_stream.h"
#include <Poco/BinaryWriter.h>
#include <Poco/BinaryReader.h>
#include "section_istream.h"
#include "text_validation.h"
#include <angelscript.h>
#include <Poco/Path.h>
#include <iostream>
namespace new_pack
{
	static const int header_size = 64;
	static const uint32_t magic = 0xDadFaded;
	struct pack::toc_entry
	{
		std::string filename; // Must be UTF-8.
		uint64_t offset;	  // We don't save this. In write mode, these are stored in a std::list, so we can take advantage of linearity to save space.
		uint64_t size;
	};
	typedef std::unordered_map<std::string, pack::toc_entry> toc_map;
	typedef std::list<pack::toc_entry *> toc_list;
	class pack::read_mode_internals
	{
		toc_map toc;
		std::istream *file;
		bool load();

	public:
		read_mode_internals(std::istream &file);
		~read_mode_internals();
		const toc_entry *get(const std::string &filename) const;
	};
	class pack::write_mode_internals
	{
		std::ostream *file;
		toc_map toc;
		toc_list ordered_toc; // Because we need to write the TOC entries in the same order as they were inserted.
		// Writes a block of zeros to the head of the file. Called once when a file is created. This header is updated when the file is finalized.
		bool put_blank_header();

	public:
		// Writes the TOC and updates the header.
		bool finalize();

		// Pack itself is responsible for composing the stream it wants and passing it in. Internals take ownership though.
		write_mode_internals(std::ostream &file);
		~write_mode_internals();
		bool put(const std::string &filename, const std::string &internal_name);
		// Get current position in the output stream.
		std::streampos tell();
	};
	bool pack::read_mode_internals::load()
	{
		file->seekg(0, file->end);
		uint64_t file_size = file->tellg();
		file->seekg(0);
		if (!file->good())
		{
			return false; // Unseekable stream presumably.
		}
		Poco::BinaryReader direct_reader(*file, Poco::BinaryReader::LITTLE_ENDIAN_BYTE_ORDER);
		Poco::BinaryReader *reader = &direct_reader; // Because BinaryReader deletes the assignment operator and we're going to swap underlying streams later.
		// File should begin with magic constant.
		uint32_t read_magic = 0;
		reader->readRaw((char *)&read_magic, 4);
		if (read_magic != magic)
		{
			return false;
		}
		uint64_t toc_offset;
		*reader >> toc_offset;
		if (toc_offset >= file_size || toc_offset < 64)
		{
			return false;
		}
		uint32_t checksum;
		*reader >> checksum;
		file->seekg(toc_offset);
		if (!file->good())
		{
			return false;
		}
		// We need to be computing the checksum while processing the TOC, so the binary reader is reconstructed to include the checksum node.

		checksum_istream check(*file);

		Poco::BinaryReader check_reader(check, Poco::BinaryReader::LITTLE_ENDIAN_BYTE_ORDER);
		reader = &check_reader;
		uint64_t current_offset = 64; // Just past the header.
		while (true)
		{
			toc_entry entry;
			uint64_t name_length = 0;
			reader->read7BitEncoded(name_length);

			// Don't get tricked into allocating a ridiculous amount of memory:
			if (name_length > 65535)
			{
				return false;
			}
			entry.filename.resize(name_length);
			reader->readRaw(&entry.filename[0], name_length);
			// Enforce the rules: file names must be UTF8 and may not contain characters in the non-printable ASCII ranges.
			if (!is_valid_utf8(entry.filename))
			{
				return false;
			}
			// And lastly, check that we aren't loading a duplicate:
			if (toc.find(entry.filename) != toc.end())
			{
				return false;
			}
			entry.offset = current_offset;
			// Because the checksum stream is in-between the source file and binary reader, we must perform goodness checks on the checksum stream, not directly on the file.
			if (!check.good())
			{
				return false;
			}
			reader->read7BitEncoded(entry.size);
			current_offset += entry.size;
			toc[entry.filename] = entry;
			// We may now be EOF, which indicates successful parsing of TOC.

			if (check.tellg() == file_size)
			{
				break;
			}
		}
		// Getting here means we ingested the TOC successfully. The last steps are to verify the checksum and to make sure the file offsets add up to the entire data block.
		if (check.get_checksum() != checksum)
		{
			return false;
		}
		if (current_offset != toc_offset)
		{
			return false;
		}
		return true;
	}
	pack::read_mode_internals::read_mode_internals(std::istream &file)
		: toc()
	{
		this->file = &file;

		if (!load())
		{
			throw std::runtime_error("Unable to load this pack file.");
		}
	}
	pack::read_mode_internals::~read_mode_internals()
	{
	}
	const pack::toc_entry *pack::read_mode_internals::get(const std::string &filename) const
	{
		toc_map::const_iterator i = toc.find(filename);
		if (i == toc.end())
		{
			return NULL;
		}
		return &(i->second);
	}
	bool pack::write_mode_internals::put_blank_header()
	{
		if (!file->good())
		{
			return false;
		}
		char header[header_size];
		memset(header, 0, header_size);
		file->write(header, header_size);
		return true;
	}
	bool pack::write_mode_internals::finalize()
	{
		std::streampos toc_offset = file->tellp();
		if (toc_offset == -1)
		{
			return false;
		}
		// This ostream computes a checksum on incoming data and then passes it through to the attached sink.
		checksum_ostream check(*file);
		Poco::BinaryWriter writer(check, Poco::BinaryWriter::LITTLE_ENDIAN_BYTE_ORDER);

		for (toc_list::iterator i = ordered_toc.begin(); i != ordered_toc.end(); i++)
		{
			toc_entry &entry = **i;
			writer.write7BitEncoded(entry.filename.length());
			writer.writeRaw(entry.filename);
			writer.write7BitEncoded(entry.size);
		}
		writer.flush();
		// Capture the checksum at this point because we don't want to include the header in it.
		uint32_t checksum = check.get_checksum();
		// Now go back and update the header:
		file->seekp(0);
		writer.writeRaw((const char *)&magic, 4);
		writer << toc_offset;
		writer << checksum;
		writer.flush();

		return file->tellp() != -1;
	}
	pack::write_mode_internals::write_mode_internals(std::ostream &file)
		: toc()
	{
		this->file = &file;
		if (!put_blank_header())
		{
			throw std::runtime_error("Unable to write header to the file.");
		}
	}
	pack::write_mode_internals::~write_mode_internals()
	{
		delete file;
	}
	bool pack::write_mode_internals::put(const std::string &filename, const std::string &internal_name)
	{
		try
		{
			if (toc.find(internal_name) != toc.end())
			{
				return false; // Duplicate.
			}
			if (!is_valid_utf8(internal_name))
			{
				return false;
			}
			if (internal_name.length() > 65535)
			{
				return false;
			}
			Poco::FileInputStream in_file(filename);
			toc_entry entry;
			entry.filename = internal_name;
			in_file.seekg(0, in_file.end);
			std::streampos size = in_file.tellg();
			if (size == -1)
			{
				return false;
			}
			in_file.seekg(0);
			entry.size = (uint64_t)size;
			// We need to insert a copy of the TOC entry into the map, then insert a pointer to that into the list.
			toc_entry *inserted = &toc[internal_name];
			*inserted = entry;
			ordered_toc.push_back(inserted);
			Poco::StreamCopier::copyStream(in_file, *file);
		}
		catch (std::exception &)
		{
			// Was the TOC entry already added?
			toc_map::iterator i = toc.find(internal_name);
			if (i != toc.end())
			{
				// This is a file system error, out of disk space, etc. Throw here and don't bother fixing bookkeeping, because your pack is almost certainly corrupt at this point anyway.
				throw std::runtime_error("Critical error while writing data to pack.");
			}
			return false;
		}
		return true;
	}
	std::streampos pack::write_mode_internals::tell()
	{
		return file->tellp();
	}
	void pack::set_pack_name(const std::string &name)
	{
		pack_name = Poco::Path(name).absolute().toString();
	}
	pack::pack()
	{
		open_mode = OPEN_NOT;
	}
	pack::pack(const pack &other)
	{
		if (other.open_mode != OPEN_READ)
		{

			throw std::invalid_argument("Only read mode packs can be copy constructed.");
		}

		open_mode = OPEN_READ;
		read = other.read;
		pack_name = other.pack_name;
	}
	pack::~pack()
	{

		close();
	}
	bool pack::create(const std::string &filename, const std::string &key)
	{
		close();
		Poco::FileOutputStream *file = NULL;
		try
		{
			file = new Poco::FileOutputStream(filename);
			write = std::make_shared<write_mode_internals>(*file);
		}
		catch (std::exception &)
		{
			if (file != NULL)
			{
				delete file;
			}
			return false;
		}
		set_pack_name(filename);
		open_mode = OPEN_WRITE;
		return true;
	}
	bool pack::open(const std::string &filename, const std::string &key)
	{
		close();
		Poco::FileInputStream *file = NULL;
		try
		{
			file = new Poco::FileInputStream(filename);
			read = std::make_shared<read_mode_internals>(*file);
		}
		catch (std::exception &)
		{
			if (file != NULL)
			{
				delete file;
			}
			return false;
		}
		set_pack_name(filename);
		open_mode = OPEN_READ;
		return true;
	}
	bool pack::close()
	{
		switch (open_mode)
		{
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
	bool pack::add_file(const std::string &filename, const std::string &internal_name)
	{
		if (open_mode != OPEN_WRITE)
		{
			return false;
		}
		return write->put(filename, internal_name);
	}
	std::istream *pack::get_file(const std::string &filename) const
	{
		if (open_mode != OPEN_READ)
		{
			return nullptr;
		}
		const toc_entry *entry = read->get(filename);
		if (entry == nullptr)
		{
			return nullptr;
		}

		Poco::FileInputStream *fis = nullptr;
		try
		{
			fis = new Poco::FileInputStream(pack_name, std::ios_base::in);
			return new section_istream(*fis, entry->offset, entry->size);
		}
		catch (std::exception &)
		{
			delete fis;
			return nullptr;
		}
		return nullptr;
	}
	const std::string pack::get_pack_name() const
	{
		return pack_name;
	}
	void pack::release_pack(pack *obj)
	{
		obj->release();
	}
	std::shared_ptr<pack> pack::to_shared()
	{
		return std::make_shared<pack>(*this);
	}
	pack *pack::make()
	{
		return new pack();
	}
	void register_pack(asIScriptEngine *engine)
	{
		engine->SetDefaultNamespace("new_pack");
		engine->RegisterObjectType("pack_file", 0, asOBJ_REF);
		engine->RegisterObjectBehaviour("pack_file", asBEHAVE_FACTORY, "pack_file@ a()", asFUNCTION(pack::make), asCALL_CDECL);
		engine->RegisterObjectBehaviour("pack_file", asBEHAVE_ADDREF, "void b()", asMETHOD(pack, duplicate), asCALL_THISCALL);
		engine->RegisterObjectBehaviour("pack_file", asBEHAVE_RELEASE, "void c()", asMETHOD(pack, release), asCALL_THISCALL);
		engine->RegisterObjectMethod("pack_file", "bool create(const string &in filename, const string&in key = \"\")",
									 asMETHOD(pack, create), asCALL_THISCALL);
		engine->RegisterObjectMethod("pack_file", "bool open(const string &in filename, const string &in key = \"\")",
									 asMETHOD(pack, open), asCALL_THISCALL);
		engine->RegisterObjectMethod("pack_file", "bool close()", asMETHOD(pack, close), asCALL_THISCALL);
		engine->RegisterObjectMethod("pack_file", "bool add_file(const string &in filename, const string &in internal_name)", asMETHOD(pack, add_file), asCALL_THISCALL);

		engine->SetDefaultNamespace("");
	}
}
