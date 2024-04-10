/* datastreams.h - iostreams wrapper implementation header
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

#include <sstream>
#include <angelscript.h>
#include <Poco/BinaryReader.h>
#include <Poco/BinaryWriter.h>
#include <Poco/RefCountedObject.h>
#include <Poco/SharedPtr.h>

typedef Poco::SharedPtr<std::istream> istrPtr;
typedef Poco::SharedPtr<std::ostream> ostrPtr;
typedef Poco::SharedPtr<std::iostream> iostrPtr;

// The base datastream class. This wraps either an iostream or an istream/ostream into a Poco BinaryReader/Writer. This Poco class has functionality extremely similar to Angelscript's scriptfile addon accept that it works on streams, meaning that it can work on much more than files. We also wrap some other basics of std streams.
class datastream;
typedef void (datastream_close_callback)(datastream*);
class datastream : public Poco::RefCountedObject {
	// We access these first 2 properties so much that we will give them short names.
	Poco::BinaryReader* r;
	Poco::BinaryWriter* w;
	// We hold on to these shared pointers soley to keep the internal istream and ostream objects alive for the binary reader/writer at least until this object dies, other than that it's actually annoying to need these.
	istrPtr _istr;
	ostrPtr _ostr;
	datastream* ds; // If this object was created from another angelscript object, holds a reference to it so we can keep all parent streams alive until the close or destruction of this object.
	datastream_close_callback* close_cb; // Some advanced streams may allocate some extra user data that needs to be destroyed when a stream is closed, this is such a stream's opertunity to destroy that data.
public:
	void* user; // Free for advanced streams to use.
	bool no_close; // If set to true, the close function becomes a no-op for singleton streams like stdin/stdout.
	bool binary; // If set to false, the template read/write functions will write formatted text output instead of binary data, used by default for console streams.
	// Empty constructor (internal stream is nonexistent/closed).
	datastream() : r(NULL), w(NULL), ds(NULL), user(NULL), close_cb(NULL), no_close(false), binary(true) {}
	// Low level constructor (Allows passing separate shared pointers to input and output stream).
	datastream(istrPtr istr, ostrPtr ostr, const std::string& encoding, int byteorder, datastream* obj) : r(NULL), w(NULL), ds(NULL), user(NULL), close_cb(NULL), no_close(false), binary(true) {
		open(istr, ostr, encoding, byteorder, obj);
	}
	// Higher level constructor (Creates shared pointers for given std::ios pointer and has default arguments).
	datastream(std::ios* stream, const std::string& encoding = "", int byteorder = Poco::BinaryReader::StreamByteOrder::NATIVE_BYTE_ORDER, datastream* obj = NULL) : r(NULL), w(NULL), ds(NULL), user(NULL), close_cb(NULL), no_close(false), binary(true) {
		open(stream, encoding, byteorder, obj);
	}
	~datastream() {
		close();
	}
	bool open(istrPtr istr, ostrPtr ostr, const std::string& encoding, int byteorder, datastream* obj);
	bool open(std::ios* stream, const std::string& encoding = "", int byteorder = Poco::BinaryReader::StreamByteOrder::NATIVE_BYTE_ORDER, datastream* obj = NULL) {
		return open(dynamic_cast<std::istream*>(stream), dynamic_cast<std::ostream*>(stream), encoding, byteorder, obj);
	}
	bool close(bool close_all = false);
	std::ios* stream();
	bool seek(unsigned long long offset);
	bool seek_end(unsigned long long offset);
	bool seek_relative(long long offset);
	long long get_pos();
	bool rseek(unsigned long long offset);
	bool rseek_end(unsigned long long offset);
	bool rseek_relative(long long offset);
	long long get_rpos();
	bool wseek(unsigned long long offset);
	bool wseek_end(unsigned long long offset);
	bool wseek_relative(long long offset);
	long long get_wpos();
	std::string read(unsigned int size);
	std::string read_line();
	bool can_write();
	unsigned int write(const std::string& data);
	template<typename T> datastream& read(T& value);
	template <typename T> T read();
	template<typename T> datastream& write(T value);
	inline bool good() {
		return _istr ? _istr->good() : _ostr ? _ostr->good() : false;
	}
	inline bool eof() {
		return _istr ? _istr->eof() : _ostr ? _ostr->eof() : false;
	}
	inline bool bad() {
		return _istr ? _istr->bad() : _ostr ? _ostr->bad() : false;
	}
	inline bool fail() {
		return _istr ? _istr->fail() : _ostr ? _ostr->fail() : false;
	}
	inline void set_close_callback(datastream_close_callback* cb) {
		close_cb = cb;
	}
	inline bool close_all() {
		return close(true);
	}
	inline bool active() {
		return r || w;
	}
	inline int available() {
		return r ? r->available() : -1;
	}
	inline std::istream* get_istr() {
		return _istr.get();
	}
	inline std::ostream* get_ostr() {
		return _ostr.get();
	}
	inline std::iostream* get_iostr() {
		return _istr && dynamic_cast<std::iostream*>(_istr.get()) == dynamic_cast<std::iostream*>(_ostr.get()) ? dynamic_cast<std::iostream*>(_istr.get()) : NULL;
	}
};

// These macros simply allow the registration of a stream with a bit less typing, since there are many streams and any amount of them may be registered later.
#define f_streamargs const std::string& encoding = "", int byteorder = Poco::BinaryReader::NATIVE_BYTE_ORDER
#define p_streamargs encoding, byteorder
typedef enum {datastream_factory_none, datastream_factory_closed, datastream_factory_opened} datastream_factory_type;
template <class T, datastream_factory_type factory = datastream_factory_opened> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname);
template <class T, class S, datastream_factory_type factory = datastream_factory_closed> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname);
template <class T, class S, typename A1, datastream_factory_type factory = datastream_factory_closed> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname, const std::string& arg_types);
template <class T, class S, typename A1, typename A2, datastream_factory_type factory = datastream_factory_closed> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname, const std::string& arg_types);

void RegisterScriptDatastreams(asIScriptEngine* engine);
