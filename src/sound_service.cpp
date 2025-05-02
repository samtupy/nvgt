/* sound_service.cpp - sound service implementation code written by Caturria
 * This is responsible for providing miniaudio with data to play from various sources, from an encrypted pack file to a custom stream from the internet.
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

#include "sound_service.h"
#include <Poco/FileStream.h>
#include <vector>
#include <cassert>
#include <miniaudio.h>
#include "crypto.h"
#include "misc_functions.h" // is_valid_utf8
#include "pack.h"
#include <Poco/StringTokenizer.h>
#include <Poco/NumberFormatter.h>
#include <Poco/MemoryStream.h>
#include <Poco/NumberParser.h>
#include <sstream>
#include <iostream>
#include <unordered_map>
#include <mutex>
/**
 * The VFS is the glue between the sound service and MiniAudio.
 * We have an opaque structure -- in this case a pointer to the sound_service implementation -- and a series of callbacks which provide MiniAudio an interface to it.
 */
struct sound_service_vfs {
	ma_vfs_callbacks callbacks;
	sound_service *service;
};
#define vfs_cast(x) \
	sound_service_vfs *vfs = static_cast<sound_service_vfs *>(x); \
	if (vfs == NULL) \
	{ \
		return MA_ERROR; \
	}
#define file_cast(x) \
	std::istream *stream = static_cast<std::istream *>(x); \
	if (stream == NULL) \
	{ \
		return MA_ERROR; \
	}

class sound_service_impl : public sound_service {
	/**
	 * Default protocol which loads files directly from the file system.
	 */
	class fs_protocol : public sound_service::protocol {
		static const fs_protocol instance;

	public:
		static const protocol *get_instance() {
			return &instance;
		}
		virtual std::istream *open_uri(const char *uri, const directive_t directive) const {
			Poco::FileInputStream *stream;
			try {
				stream = new Poco::FileInputStream(uri);
				return stream;
			} catch (std::exception &) {
				return NULL; // Likely out of memory.
			}
		}
		virtual const std::string get_suffix(const directive_t &directive) const {
			return "fs";
		}
	};
	/**
	 * Default filter which performs no filtering at all and just passes its input through untouched.
	 */
	class null_filter : public filter {
		static const null_filter instance;

	public:
		static const filter *get_instance() {
			return &instance;
		}
		virtual std::istream *wrap(std::istream &source, const directive_t directive) const {
			return &source;
		}
	};

	// A template for registering protocols and filters with the sound service, along with directives and other metadata.
	template <class t>
	class service_registration {
		const t *item;
		directive_t directive; // Arbitrary data that will be sent to the filter or protocol (such as a decryption key), always use atomic operations to access.
		size_t slot;

	public:
		service_registration(const t *item, size_t slot)
			: directive() {
			this->item = item;
			this->slot = slot;
		}
		inline const t *get() const {
			return item;
		}
		inline const directive_t get_directive() const {
			return std::atomic_load_explicit(&directive, std::memory_order_acquire);
		}
		inline void set_directive(const directive_t &directive) {
			std::atomic_store_explicit(&this->directive, directive, std::memory_order_release);
		}
		inline const size_t get_slot() const {
			return slot;
		}
	};
	typedef service_registration<protocol> protocol_reg_t;
	typedef std::shared_ptr<protocol_reg_t> protocol_registration;
	typedef service_registration<filter> filter_reg_t;
	typedef std::shared_ptr<filter_reg_t> filter_registration;
	std::vector<protocol_registration> protocols;
	protocol_registration default_protocol; // Always access with atomic operations!
	typedef std::vector<filter_registration> filter_array;
	filter_array filters;
	filter_registration default_filter; // Always access with atomic operations!
	sound_service_vfs vfs;
	typedef std::unordered_map<std::string, vfs_args> temp_args_t;
	temp_args_t temp_args;
	std::mutex temp_args_mtx;
	bool set_temp_args(const std::string &triplet, const vfs_args &args) {
		std::unique_lock<std::mutex> lock(temp_args_mtx);

		return temp_args.try_emplace(triplet, args).second;
	}
	bool get_temp_args(const std::string &triplet, vfs_args &dest) {
		std::unique_lock<std::mutex> lock(temp_args_mtx);
		temp_args_t::iterator i = temp_args.find(triplet);
		if (i == temp_args.end())
			return false;
		dest = i->second;
		return true;
	}
public:
	sound_service_impl()
		: protocols(),
		  filters() {
		// Protocol slot zero means use default, so insert a fake/ null registration there to force real slots to start at one.
		protocols.push_back(nullptr);
		size_t slot = 0;
		register_protocol(fs_protocol::get_instance(), slot);
		set_default_protocol(slot);
		assert(slot == fs_protocol_slot);
		// Filters also have a special null slot at zero:
		filters.push_back(nullptr);
		register_filter(null_filter::get_instance(), slot);
		set_default_filter(slot);
		assert(slot == null_filter_slot);
		// Assemble the VFS, which gets passed to MiniAudio so that it can interface with this.
		vfs.service = this;
		vfs.callbacks.onClose = onClose;
		vfs.callbacks.onInfo = onInfo;
		vfs.callbacks.onOpen = onOpen;
		vfs.callbacks.onOpenW = NULL; // Todo: do we need this?
		vfs.callbacks.onRead = onRead;
		vfs.callbacks.onSeek = onSeek;
		vfs.callbacks.onTell = onTell;
		vfs.callbacks.onWrite = NULL;
	}
	virtual ~sound_service_impl() {
	}
	bool register_protocol(const sound_service::protocol *proto, size_t &slot) {
		try {
			protocols.push_back(std::make_shared<protocol_reg_t>(proto, protocols.size()));
			slot = protocols.size() - 1;
			return true;
		} catch (std::exception e) {
			return false;
		}
	}
	bool register_filter(const sound_service::filter *the_filter, size_t &slot) {
		try {
			filters.push_back(std::make_shared<filter_reg_t>(the_filter, filters.size()));
			slot = filters.size() - 1;
			return true;
		} catch (std::exception &) {
			return false;
		}
	}

	bool set_default_protocol(size_t slot) {
		if (slot >= protocols.size())
			return false;
		std::atomic_store(&default_protocol, protocols[slot]);
		return true;
	}
	const protocol *get_protocol(size_t slot) {
		if (slot < 0 || slot >= protocols.size())
			return nullptr;
		return protocols[slot]->get();
	}
	const protocol *get_default_protocol() {
		return std::atomic_load(&default_protocol)->get();
	}
	bool is_default_protocol(size_t slot) {
		if (slot < 0 || slot >= filters.size())
			return false;
		return protocols[slot] == std::atomic_load(&default_protocol);
	}
	bool set_default_filter(size_t slot) {
		if (slot < 0 || slot > filters.size())
			return false;
		std::atomic_store(&default_filter, filters[slot]);
		return true;
	}
	bool is_default_filter(size_t slot) {
		if (slot < 0 || slot >= filters.size())
			return false;
		return filters[slot] == std::atomic_load(&default_filter);
	}
	bool set_protocol_directive(size_t slot, const directive_t &new_directive) {
		if (slot < 0 || slot >= protocols.size())
			return false;
		protocols[slot]->set_directive(new_directive);
		return true;
	}
	const directive_t get_protocol_directive(size_t slot) const {
		if (slot < 0 || slot >= protocols.size())
			return nullptr;
		return protocols[slot]->get_directive();
	}
	bool set_filter_directive(size_t slot, const directive_t &new_directive) {
		if (slot < 0 || slot >= filters.size())
			return false;
		filters[slot]->set_directive(new_directive);
		return true;
	}
	std::string prepare_triplet(const std::string &name, const size_t protocol_slot, const directive_t protocol_directive, const size_t filter_slot, directive_t filter_directive) {
		if (protocol_slot >= protocols.size())
			return "";
		if (!is_valid_utf8(name))
			return "";
		vfs_args args;
		protocol_registration preg;
		// Slot zero means use default:
		preg = (protocol_slot == 0 ? std::atomic_load(&default_protocol) : protocols[protocol_slot]);
		args.name = name;
		args.protocol_slot = preg->get_slot();
		args.protocol_directive = protocol_directive == nullptr ? preg->get_directive() : protocol_directive;
		// Filter selection.
		filter_registration freg;
		// Filter slot zero means use default:
		freg = (filter_slot == 0 ? std::atomic_load(&default_filter) : filters[filter_slot]);
		args.filter_slot = freg->get_slot();
		args.filter_directive = (filter_directive == nullptr ? freg->get_directive() : filter_directive);
		// Build our triplet. This is the name that will actually be remembered by MiniAudio's resource manager.
		std::stringstream triplet;
		triplet << name
		        << "\x1e"
		        << args.protocol_slot
		        << "\x1e"
		        << preg->get()->get_suffix(args.protocol_directive);
		set_temp_args(triplet.str(), args);

		return triplet.str();
	}
	std::istream *open_triplet(const char *triplet, size_t filter_slot = 0, const directive_t filter_directive = nullptr) {
		// Get our VFS args back.
		vfs_args args;
		if (!get_temp_args(triplet, args))
			return nullptr;
		const protocol *proto = protocols[args.protocol_slot]->get();
		std::istream *result = proto->open_uri(args.name.c_str(), args.protocol_directive);

		if (result)
			return apply_filter(result, args.filter_slot, args.filter_directive);
		return nullptr;
	}
	bool cleanup_triplet(const std::string &triplet) {
		std::unique_lock<std::mutex> lock(temp_args_mtx);
		temp_args_t::iterator i = temp_args.find(triplet);
		if (i == temp_args.end())
			return false;
		temp_args.erase(i);
		return true;
	}
	std::istream *apply_filter(std::istream *source, size_t filter_slot = 0, const directive_t filter_directive = nullptr) {
		if (source == NULL)
			return NULL;
		const filter *f = filters[filter_slot]->get();
		std::istream *filtered = f->wrap(*source, filter_directive);
		// For now just return the raw source if the filter rejects it.
		// Todo: decide how we want to handle filter rejection. Should it pass through? reject the source outright? Make this configurable globally at the sound service level? Or let filters handle it case by case via directive?
		if (filtered == nullptr) {
			source->seekg(0);
			return source;
		}
		return filtered;
	}

	sound_service_vfs *get_vfs() {
		return &vfs;
	}

private:
	// Callbacks that glue MiniAudio to the sound service.

	static ma_result onOpen(ma_vfs *pVFS, const char *pFilePath, ma_uint32 openMode, ma_vfs_file *pFile) {
		vfs_cast(pVFS);
		std::istream *file = vfs->service->open_triplet(pFilePath);
		if (file == NULL) {
			return MA_ERROR; // Not found, not permitted, etc.
		}
		*pFile = file;

		return MA_SUCCESS;
	}
	static ma_result onClose(ma_vfs *pVFS, ma_vfs_file file) {

		file_cast(file);
		delete stream;

		return MA_SUCCESS;
	}
	static ma_result onRead(ma_vfs *pVFS, ma_vfs_file file, void *pDst, size_t sizeInBytes, size_t *pBytesRead) {
		file_cast(file);
		stream->read((char *)pDst, sizeInBytes);
		if (pBytesRead) *pBytesRead = stream->gcount();

		return MA_SUCCESS;
	}
	static ma_result onSeek(ma_vfs *pVFS, ma_vfs_file file, ma_int64 offset, ma_seek_origin origin) {
		file_cast(file);
		stream->clear();
		std::ios_base::seekdir dir;
		switch (origin) {
			case ma_seek_origin_start:
				dir = stream->beg;
				break;
			case ma_seek_origin_current:
				dir = stream->cur;
				break;
			case ma_seek_origin_end:
				dir = stream->end;
				break;
			default: // Should never get here.
				return MA_ERROR;
		}
		stream->seekg(offset, dir);

		return MA_SUCCESS;
	}
	static ma_result onTell(ma_vfs *pVFS, ma_vfs_file file, ma_int64 *pCursor) {
		file_cast(file);
		*pCursor = stream->tellg();
		return MA_SUCCESS;
	}
	static ma_result onInfo(ma_vfs *pVFS, ma_vfs_file file, ma_file_info *pInfo) {
		file_cast(file);
		stream->clear();
		size_t cursor = stream->tellg();
		stream->seekg(0, stream->end);
		pInfo->sizeInBytes = stream->tellg();
		stream->seekg(cursor, stream->beg);
		return MA_SUCCESS;
	}
};

std::unique_ptr<sound_service> sound_service::make() {
	try {
		return std::make_unique<sound_service_impl>();
	} catch (std::exception &) {
		throw std::runtime_error("Unable to create the sound service.");
	}
}
sound_service::sound_service() {
}
sound_service::~sound_service() {
}
const sound_service_impl::fs_protocol sound_service_impl::fs_protocol::instance;
const sound_service_impl::null_filter sound_service_impl::null_filter::instance;

// ChaCha encryption sound service filter
const sound_service::filter *encryption_filter::get_instance() {
	return &instance;
}
encryption_filter::encryption_filter() {
}
std::istream *encryption_filter::wrap(std::istream &source, const directive_t directive) const {
	// Key is expected to have been passed in through the directive interface.
	const std::shared_ptr<const std::string> key = std::static_pointer_cast<const std::string>(directive);
	if (key == nullptr)
		return &source;
	try {
		return new chacha_istream(source, *key);
	} catch (std::exception &) {
		// Not encrypted or not valid.
		return nullptr;
	}
}
encryption_filter encryption_filter::instance;

// Memory buffer sound service protocol implementation
static std::atomic<uint64_t> next_memory_id = 0;
struct memory_args {
	const void *data;
	size_t size;
	uint64_t id; // Prevents caching by resource manager.
};

std::istream *memory_protocol::open_uri(const char *uri, const directive_t directive) const {
	// This proto doesn't care about the URI itself.
	std::shared_ptr<const memory_args> args = std::static_pointer_cast<const memory_args>(directive);
	if (args == nullptr)
		return nullptr;
	return new Poco::MemoryInputStream((const char *)args->data, args->size);
}
const std::string memory_protocol::get_suffix(const directive_t &directive) const {
	std::shared_ptr<const memory_args> args = std::static_pointer_cast<const memory_args>(directive);
	return Poco::NumberFormatter::format(args->id);
}
directive_t memory_protocol::directive(const void *data, size_t size) {
	std::shared_ptr<memory_args> args = std::make_shared<memory_args>();
	args->data = data;
	args->size = size;
	args->id = next_memory_id++;
	return args;
}
const memory_protocol memory_protocol::instance;
const sound_service::protocol *memory_protocol::get_instance() {
	return &instance;
}

// pack file sound service protocol
std::istream *pack_protocol::open_uri(const char *uri, const directive_t directive) const {
	std::shared_ptr<const pack_interface> obj = std::static_pointer_cast<const pack_interface>(directive);
	if (obj == nullptr)
		return nullptr;
	std::istream *item = obj->get_file(uri);
	return item;
}
const std::string pack_protocol::get_suffix(const directive_t &directive) const {
	std::shared_ptr<const pack_interface> obj = std::static_pointer_cast<const pack_interface>(directive);
	if (obj == nullptr)
		return "error";
	return obj->get_pack_name();
}
const pack_protocol pack_protocol::instance;
const sound_service::protocol *pack_protocol::get_instance() {
	return &instance;
}
