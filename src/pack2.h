/* pack.h - pack file implementation header
 * Note: temporarily namespaced as new_pack to avoid name collision problems on the C++ side during integration: will be changed once the original packfile is removed.
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
#include <string>
#include <Poco/RefCountedObject.h>
#include <memory>
class asIScriptEngine;
class datastream;
class CScriptArray;
namespace new_pack
{
	class pack : public Poco::RefCountedObject
	{
		enum open_modes
		{
			OPEN_NOT = 0,
			OPEN_READ,
			OPEN_WRITE,
		};
		class read_mode_internals;
		class write_mode_internals;

		open_modes open_mode;
		// bleh... can't be a union because these need to be shared_ptrs.
		std::shared_ptr<read_mode_internals> read;
		std::shared_ptr<write_mode_internals> write;
		std::string pack_name; // When a pack is opened for reading, this should be set to the name of the pack file so we can create new streams to open files.
		std::string key;
		// Sets the pack name, converting it to an absolute path if necessary.
		void set_pack_name(const std::string &name);

	public:
		struct toc_entry;

		pack();
		// Copy constructor. Can only copy read mode packs. Only for safely providing immutable packs to the sound system. Don't give this to script.
		pack(const pack &other);
		~pack();
		bool create(const std::string &filename, const std::string &key = "");
		bool open(const std::string &filename, const std::string &key = "", uint64_t pack_offset = 0, uint64_t pack_size = 0);

		bool close();
		bool add_file(const std::string &filename, const std::string &internal_name);
		bool file_exists(const std::string &filename);
		// Gets a raw istream that points to the requested file. This is not the version that's given to script.
		std::istream *get_file(const std::string &filename) const;
		// Returns a datastream for script that points to the requested file.
		datastream *get_file_script(const std::string &filename, const std::string &encoding, int byteorder);
		bool get_active();
		int64_t get_file_count();
		bool extract_file(const std::string &internal_name, const std::string &file_on_disk);

		CScriptArray *list_files();
		// Returns the absolute path to this pack file on disk.
		const std::string get_pack_name() const;
		/**
		 * Creates a shared pointer to this object that can be used as a sound_service directive.
		 * It calls duplicate() on the object, then returns a shared pointer which calls release() instead of deleting directly.
		 */
		std::shared_ptr<pack> to_shared();
		// Releases the given pack object. Used by to_shared().
		static void release_pack(pack *obj);
		// Angelscript factory behaviour
		static pack *make();
	};
	// Engine registration
	void register_pack(asIScriptEngine *engine);
}
