/* sound_service.h - sound service implementation header
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
#include <istream>
#include <memory>
#include <mutex>
typedef std::shared_ptr<const void> directive_t;
struct sound_service_vfs;
struct vfs_args {
	std::string name;
	size_t protocol_slot = 0;
	directive_t protocol_directive;
	size_t filter_slot = 0;
	directive_t filter_directive;
};
class sound_service {
public:
	static const size_t fs_protocol_slot = 1;
	static const size_t null_filter_slot = 1;
	/**
	 * Sound_service protocol class.
	 * Instances of this class provide a bridge between the sound system and your arbitrary data sources, such as packs, archives, the internet, etc.
	 * How to implement:
	 * First, define a std::istream that works with your custom data source. This is the hard part. It involves defining a new streambuf that can read and seek your custom data source (Poco's BasicBufferedStreamBuf class takes a lot of the pain out of this; see encryption_filter.cpp or pack_protocol.cpp for examples). Then, define a std::istream which wraps your streambuf.
	 * Finally, define your protocol class.
	 * The only method that must be defined is open_uri. It must return a pointer to a std::istream if the provided uri make sense for your custom data protocol, or nullptr otherwise.
	 * The sound system will take ownership of the returned pointer and delete it when the script is done with the sound source it represents.
	 * It is recommended that your protocols be stateless singletons, meaning your protocol class should feature a single instance as a private static property and a static method to fetch a pointer to it as follows:
	 * private:
	 * static my_protocol instance;
	 * public:
	 * sound_service::protocol* get_instance();
	 */
	class protocol {
	public:
		virtual std::istream *open_uri(const char *uri, const directive_t directive) const = 0;
		virtual const std::string get_suffix(const directive_t &directive) const = 0;
	};
	/**
	 * Sound_service filter class.
	 * Instances of this class provide a means of transforming data before delivering it to the sound system.
	 * The most common use case for this is decryption.
	 * How to implement:
	 * First, define a new streambuf that will receive a std::istream, read data from it, perform your desired transformation, and finally output the transformed data. This is the hard part. Poco's BasicBufferedStreamBuf class can take a lot of the pain out of this. See encryption_filter.cpp for an example.
	 * Next, define a new std::istream which wraps your streambuf.
	 * Finally define your filter class.
	 * The only method which must be implemented is wrap. This method should receive a std::istream as input, and should return a pointer to your new stream if the data is able to be transformed, or nullptr otherwise.
	 * Note: if your stream accepts the provided input, it becomes responsible for cleaning it up. Don't forget to delete it from within your destructor; leaked data sources will add up to trouble fast in a game context. If you reject the input (return nullptr), then you are not responsible for its cleanup.
	 * It is recommended that you implement filters as largely stateless singletons. The recommended pattern is to define a static instance property and a method that returns a pointer to it, like so:
	 * private:
	 * static my_filter instance;
	 * public:
	 * sound_service::protocol* get_instance();
	 *
	 */
	class filter {
	public:
		// Attaches itself to the given input stream. The wrapping istream is expected to take ownership of its data source and clean it up on destruction.
		virtual std::istream *wrap(std::istream &source, const directive_t directive) const = 0;
	};
	sound_service();
	virtual ~sound_service();
	/**
	 * Protocol and filter registration.
	 * To add support for new data sources and transformations to the sound service, you must first register them.
	 * Protocols (data sources) can be registered with the register_protocol method. Filters can be registered using the register_filter method.
	 * Both of these methods take a pointer to a protocol or filter instance respectively, and a variable that will receive the slot number.
	 * The slot number is simply the index in an internal array where your protocol or filter has been stored. You'll need to keep track of this number if you want to perform certain operations later, such as setting your new protocol as default, or using it directly to open a sound.
	 * Protocols and filters are singletons, and should generally not carry mutable state. It goes without saying that they must live as long as the sound service does, which is generally the lifetime of the application. For this reason, we suggest defining them as static instance properties on the classes themselves. The sound service will not attempt to delete these.
	 */
	virtual bool register_protocol(const protocol *proto, size_t &slot) = 0;
	virtual bool register_filter(const filter *the_filter, size_t &slot) = 0; // Takes ownership.
	virtual bool set_default_protocol(size_t slot) = 0; // Must be valid (pre-existing) protocol slot. Once set, requests which don't specify a protocol will go to this one.
	virtual const protocol *get_protocol(size_t slot) = 0;
	virtual bool is_default_protocol(size_t slot) = 0;
	virtual bool set_default_filter(size_t slot) = 0;
	virtual bool is_default_filter(size_t slot) = 0;
	// Changes the default directive (such as an archive file name) that the given protocol uses.
	virtual bool set_protocol_directive(size_t slot, const directive_t &new_directive) = 0;
	virtual const directive_t get_protocol_directive(size_t slot) const = 0;
	// Changes the default directive (such as a decryption key) that the given filter uses.
	virtual bool set_filter_directive(size_t slot, const directive_t &new_directive) = 0;
	/**
	 * Converts a plain URI into a triplet that can be uniquely identified by the sound system.
	 * A triplet contains the original URI, a protocol identifier and a suffix, each separated by an ASCII "Record separator" character (0X1E).
	 * Since this method's input is validated as printable text, this separator character is guaranteed not to appear, making it ideal as a separator.
	 * The protocol identifier is just its slot number, as this is guaranteed to be unique for the lifetime of an application instance.
	 * The suffix is up to the protocol, but should be derived from the provided directive. For example, the suffix provided by the pack protocol is just the absolute path to the pack file on disk.
	 * This guarantees that assets are always loaded even if they have the same name as a previously loaded asset from a different origin.
	 */
	virtual std::string prepare_triplet(const std::string &name, const size_t protocol_slot = 0, const directive_t protocol_directive = nullptr, const size_t filter_slot = 0, const directive_t filter_directive = nullptr) = 0;
	/**
	 * Opens a triplet
	 * Pass the same arguments to this that you passed to name_to_triplet earlier.
	 */
	virtual std::istream *open_triplet(const char *triplet, size_t filter_slot = 0, const directive_t filter_directive = nullptr) = 0;
	/**
	 * Preparing a triplet involves provision of internal state that must be dealt with after opening the asset.ABC
	 * Don't forget to call this or you leak.
	 */
	virtual bool cleanup_triplet(const std::string &triplet) = 0;
	// The VFS is how Miniaudio itself communicates with this.
	virtual sound_service_vfs *get_vfs() = 0;
	static std::unique_ptr<sound_service> make();
};

// filters and protocols
class encryption_filter : public sound_service::filter {
public:
	static const sound_service::filter *get_instance();
	encryption_filter();
	virtual std::istream *wrap(std::istream &source, const directive_t directive) const;
	static encryption_filter instance;
};
class memory_protocol : public sound_service::protocol {
	static const memory_protocol instance;
public:
	virtual std::istream *open_uri(const char *uri, const directive_t directive) const;
	virtual const std::string get_suffix(const directive_t &directive) const;
	static const protocol *get_instance();
	/**
	 * Returns a directive_t that wraps a memory buffer; don't try to do this any other way!
	 * This does not take ownership of your data pointer; you're still responsible for cleaning it up!
	 */
	static directive_t directive(const void *data, size_t size);
};
class pack_protocol : public sound_service::protocol {
	static const pack_protocol instance;
public:
	virtual std::istream *open_uri(const char *uri, const directive_t directive) const;
	virtual const std::string get_suffix(const directive_t &directive) const;
	static const protocol *get_instance();
};
