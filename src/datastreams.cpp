/* datastreams.cpp - iostreams wrapper implementation code
 * When I started learning c++ I was quite confused by std streams and considered them to be bulky and generally useless. However an extended period of considering how much I should use the poco c++ libraries caused me to look at their headers so much that I finally learned how useful these things can be especially with the collection of streams provided by Poco, and thus this is an attempt to wrap them.
 * If a hex file is stored on the internet compressed, we will be able to:
 * hex_decoder stream(deflating_reader(internet_session.get("https://path.to/file"))); string first4 = stream.read(4);
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

#include <exception>
#include <Poco/Base32Decoder.h>
#include <Poco/Base32Encoder.h>
#include <Poco/Base64Decoder.h>
#include <Poco/Base64Encoder.h>
#include <Poco/BinaryReader.h>
#include <Poco/BinaryWriter.h>
#include <Poco/CountingStream.h>
#include <Poco/DeflatingStream.h>
#include <Poco/Exception.h>
#include <Poco/FileStream.h>
#include <Poco/Format.h>
#include <Poco/HexBinaryDecoder.h>
#include <Poco/HexBinaryEncoder.h>
#include <Poco/InflatingStream.h>
#include <Poco/LineEndingConverter.h>
#include <Poco/NullStream.h>
#include <Poco/RandomStream.h>
#include <Poco/RefCountedObject.h>
#include <Poco/SharedPtr.h>
#include <Poco/StreamCopier.h>
#include <Poco/TeeStream.h>
#include <Poco/TextEncoding.h>
#include <Poco/Zip/PartialStream.h>
#include <iostream>
#include <sstream>
#include <string>
#include "datastreams.h"
#include "nvgt.h" // subsystems.
using namespace Poco;

// Global datastream singletons for cin, cout and cerr.
datastream* ds_cout = NULL;
datastream* ds_cin = NULL;
datastream* ds_cerr = NULL;

bool datastream::open(istrPtr istr, ostrPtr ostr, const std::string& encoding, int byteorder, datastream* obj) {
	if(no_close) return false; // This stream cannot be reopened.
	if(r || w) close();
	if(!istr && !ostr) return false;
	if(encoding.empty()) {
		r = istr? new BinaryReader(*istr, BinaryReader::StreamByteOrder(byteorder)) : NULL;
		w = ostr? new BinaryWriter(*ostr, BinaryWriter::StreamByteOrder(byteorder)) : NULL;
	} else {
		TextEncoding& enc = TextEncoding::byName(encoding);
		r = istr? new BinaryReader(*istr, enc, BinaryReader::StreamByteOrder(byteorder)) : NULL;
		w = ostr? new BinaryWriter(*ostr, enc, BinaryWriter::StreamByteOrder(byteorder)) : NULL;
	}
	ds = obj;
	_istr = istr;
	_ostr = ostr;
	return true;
}
bool datastream::close(bool close_all) {
	if(no_close || (!r && !w)) return false; // Nothing opened or stream was marked unclosable, the only fail case.
	if(close_cb) {
		close_cb(this);
		close_cb = NULL;
	}
	if(r) delete r;
	if(w) delete w;
	r = NULL;
	w = NULL;
	bool is_iostr = _istr && dynamic_cast<std::iostream*>(_istr.get()) != NULL;
	_istr = NULL;
	if(!is_iostr) _ostr = NULL;
	if(ds) {
		if(close_all) ds->close(close_all);
		ds->release();
	}
	ds = NULL;
	user = NULL;
	return true; 
}
std::ios* datastream::stream() {
	// Returns the opened stream so that we can get relatively easy access to it's functionality that goes beyond read/write. We can return one value here because even though we have both istr and ostr pointers, either they will be equal, or one will be null and if not this class is being used in an undefined circumstance.
	if(_istr) return _istr.get();
	else return _ostr.get();
}
bool datastream::seek(unsigned long long offset) {
	if(!r && !w) return false;
	if(_istr) {
	if(!r->eof()) _istr->clear();
		_istr->seekg(offset, std::ios::beg);
	}
	if(_ostr) _ostr->seekp(offset, std::ios::beg);
	return r && r->good() || w && w->good();
}
bool datastream::seek_end(unsigned long long offset) {
	if(!r && !w) return false;
	if(_istr) {
	if(r->eof()) _istr->clear();
		_istr->seekg(offset, std::ios::end);
	}
	if(_ostr) _ostr->seekp(offset, std::ios::end);
	return r && r->good() || w && w->good();
}
bool datastream::seek_relative(long long offset) {
	if(!r && !w) return false;
	if(_istr) {
	if(r->eof()) _istr->clear();
		_istr->seekg(offset, std::ios::cur);
	}
	if(_ostr) _ostr->seekp(offset, std::ios::cur);
	return r && r->good() || w && w->good();
}
bool datastream::rseek(unsigned long long offset) {
	if(_istr) {
	if(r->eof()) _istr->clear();
		_istr->seekg(offset, std::ios::beg);
	}
	return _istr? _istr->good() : false;
}
bool datastream::rseek_end(unsigned long long offset) {
	if(_istr) {
	if(r->eof()) _istr->clear();
		_istr->seekg(offset, std::ios::end);
	}
	return _istr? _istr->good() : false;
}
bool datastream::rseek_relative(long long offset) {
	if(_istr) {
	if(r->eof()) _istr->clear();
		_istr->seekg(offset, std::ios::cur);
	}
	return _istr? _istr->good() : false;
}
bool datastream::wseek(unsigned long long offset) {
	if(_ostr) _ostr->seekp(offset, std::ios::beg);
	return _ostr? _ostr->good() : false;
}
bool datastream::wseek_end(unsigned long long offset) {
	if(_ostr) _ostr->seekp(offset, std::ios::end);
	return _ostr? _ostr->good() : false;
}
bool datastream::wseek_relative(long long offset) {
	if(_ostr) _ostr->seekp(offset, std::ios::cur);
	return _ostr? _ostr->good() : false;
}
long long datastream::get_pos() {
	if(_istr) return _istr->tellg();
	else if(_ostr) return _ostr->tellp();
	else return 0;
}
long long datastream::get_rpos() {
	return _istr? (long long)_istr->tellg() : -1;
}
long long datastream::get_wpos() {
	return _ostr? (long long)_ostr->tellp() : -1;
}
std::string datastream::read(unsigned int size) {
	if(!r) return "";
	std::string output;
	try {
		if(size > 0) r->readRaw(size, output);
		else StreamCopier::copyToString(*_istr, output);
	} catch(std::exception) { return ""; }
	return output;
}
std::string datastream::read_line() {
	if(!_istr) return "";
	std::string result;
	std::getline(*_istr, result);
	return result;
}
bool datastream::can_write() {
	// Todo: Cache whether most of the logic in this function needs to be performed so it doesn't happen on consequtive writes.
	if(!w) return false;
	if(r && w) _ostr->seekp(_istr->tellg()); // Make sure that read and write pointers are in sync.
	if(r && r->eof()) _istr->clear(); // Should we seek here or something?
	return true;
}
unsigned int datastream::write(const std::string& data) {
	if(!can_write()) return 0;
	std::streamsize pos = _ostr->tellp();
	try { w->writeRaw(data); }
	catch(std::exception) { return long(_ostr->tellp()) - pos; }
	return long(_ostr->tellp()) - pos; // This is the only function with the extra tellp operations, for bgt backwards compatibility.
}
template<typename T> datastream& datastream::read(T& value) {
	if(!r) return *this;
	binary? (*r) >> value : (*_istr) >> value;
	return *this;
}
template <typename T> T datastream::read() {
	T value;
	if constexpr(std::is_same<T, std::string>::value) value = "";
	else value = 0;
	if(!r) return value;
	binary? (*r) >> value : (*_istr) >> value;
	return value;
}
template<typename T> datastream& datastream::write(T value) {
	if(!can_write()) return *this;
	binary? (*w) << value : (*_ostr) << value;
	return *this;
}

// This can be used for any datastream that wants to allow a default constructor E. stream is in closed state.
datastream* datastream_empty_factory() { return new datastream(); }
// Method that casts anything back to the base datastream class, which in nvgt wraps stringstream.
// This is not a true cast in c++ due to the fact that all datastreams in nvgt use the same c++ class internally. Instead, we add a reference and return the pointer that is passed.
datastream* datastream_cast_to(datastream* ds) {
	if(!ds) return NULL;
	ds->duplicate();
	return ds;
}
// The opposite. Here we attempt casting the pointer returned by ds->stream() to the c++ stream type that is being wrapped and return a pointer if successful/null if not.
template<class T> datastream* datastream_cast_from(datastream* ds) {
	if(!ds) return NULL;
	if(dynamic_cast<T*>(ds->stream())) {
		ds->duplicate();
		return ds;
	}
	return NULL;
}
// Open and factory functions for datastreams who's internal stream takes no arguments and thus can be opened by default.
template <class T> bool datastream_simple_open(datastream* ds, f_streamargs) { return ds->open(new T(), p_streamargs); }
template <class T> datastream* datastream_simple_factory(f_streamargs) { return new datastream(new T(), p_streamargs); }

// This function set registers all generic methods and/or properties of a datastream class, sans all non-default factory/open functions. The template parameter should be the c++ stream type being wrapped, such as stringstream of FileStream.
template<typename T> void RegisterDatastreamReadwrite(asIScriptEngine* engine, const std::string& classname, const std::string& type_name) {
	engine->RegisterObjectMethod(classname.c_str(), format("%s& opShr(%s&out)", classname, type_name).c_str(),	 asMETHODPR(datastream, read<T>, (T&), datastream&), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), format("%s read_%s()", type_name, type_name).c_str(), asMETHODPR(datastream, read<T>, (), T), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), format("%s& opShl(%s)", classname, type_name).c_str(), asMETHODPR(datastream, write<T>, (T), datastream&), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), format("%s& write_%s(%s)", classname, type_name, 	type_name).c_str(), asMETHODPR(datastream, write<T>, (T), datastream&), asCALL_THISCALL);
}
template <class T, datastream_factory_type factory> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname) {
	engine->RegisterObjectType(classname.c_str(), 0, asOBJ_REF);
	if constexpr(factory == datastream_factory_closed) engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_FACTORY, format("%s@ d()", classname).c_str(), asFUNCTION(datastream_empty_factory), asCALL_CDECL);
	else if constexpr(factory == datastream_factory_opened) {
		engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_FACTORY, format("%s@ s(const string&in = \"\", int byteorder = 1)", classname).c_str(), asFUNCTION((datastream_simple_factory<T>)), asCALL_CDECL);
		engine->RegisterObjectMethod(classname.c_str(), "bool open(const string&in = \"\", int byteorder = 1)", asFUNCTION((datastream_simple_open<T>)), asCALL_CDECL_OBJFIRST);
	}
	engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_ADDREF, "void f()", asMETHOD(datastream, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_RELEASE, "void f()", asMETHOD(datastream, release), asCALL_THISCALL);
	if(classname != "datastream") engine->RegisterObjectMethod(classname.c_str(), "datastream@ opImplCast()", asFUNCTION(datastream_cast_to), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("datastream", format("%s@ opCast()", classname).c_str(), asFUNCTION(datastream_cast_from<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(classname.c_str(), "bool close(bool = false)", asMETHOD(datastream, close), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool close_all()", asMETHOD(datastream, close_all), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool get_active() const property", asMETHOD(datastream, active), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "int get_available() const property", asMETHOD(datastream, available), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool seek(uint64)", asMETHOD(datastream, seek), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool seek_end(uint64 = 0)", asMETHOD(datastream, seek_end), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool seek_relative(int64)", asMETHOD(datastream, seek_relative), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "int64 get_pos() const property", asMETHOD(datastream, get_pos), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool rseek(uint64)", asMETHOD(datastream, rseek), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool rseek_end(uint64 = 0)", asMETHOD(datastream, rseek_end), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool rseek_relative(int64)", asMETHOD(datastream, rseek_relative), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "int64 get_rpos() const property", asMETHOD(datastream, get_rpos), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool wseek(uint64)", asMETHOD(datastream, wseek), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool wseek_end(uint64 = 0)", asMETHOD(datastream, wseek_end), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool wseek_relative(int64)", asMETHOD(datastream, wseek_relative), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "int64 get_wpos() const property", asMETHOD(datastream, get_pos), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "string read(uint = 0)", asMETHODPR(datastream, read, (unsigned int), std::string), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "string read_line()", asMETHOD(datastream, read_line), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "uint write(const string&in)", asMETHODPR(datastream, write, (const std::string&), unsigned int), asCALL_THISCALL);
	RegisterDatastreamReadwrite<char>(engine, classname, "int8");
	RegisterDatastreamReadwrite<unsigned char>(engine, classname, "uint8");
	RegisterDatastreamReadwrite<short>(engine, classname, "int16");
	RegisterDatastreamReadwrite<unsigned short>(engine, classname, "uint16");
	RegisterDatastreamReadwrite<int>(engine, classname, "int");
	RegisterDatastreamReadwrite<unsigned int>(engine, classname, "uint");
	RegisterDatastreamReadwrite<long long>(engine, classname, "int64");
	RegisterDatastreamReadwrite<unsigned long long>(engine, classname, "uint64");
	RegisterDatastreamReadwrite<float>(engine, classname, "float");
	RegisterDatastreamReadwrite<double>(engine, classname, "double");
	RegisterDatastreamReadwrite<std::string>(engine, classname, "string");
	engine->RegisterObjectProperty(classname.c_str(), "bool binary", asOFFSET(datastream, binary));
	engine->RegisterObjectMethod(classname.c_str(), "bool get_good() property", asMETHOD(datastream, good), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool get_bad() property", asMETHOD(datastream, bad), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool get_fail() property", asMETHOD(datastream, fail), asCALL_THISCALL);
	engine->RegisterObjectMethod(classname.c_str(), "bool get_eof() property", asMETHOD(datastream, eof), asCALL_THISCALL);
}

// While the below gets repetitive, it makes actually registering most intermediet stream types far easier in the end. The below template functions can handle the basic registration of any generic stream that connects to another one, including those that take a couple of arguments. The angelscript registration functions include factories and open functions for such streams, meaning that only custom functions on streams need to be registered.
template <class T, class S> bool connect_stream_open(datastream* ds, datastream* ds_connect, f_streamargs) {
	if(!ds_connect) return false;
	SharedPtr<S> stream;
	if constexpr(std::is_same<S, std::istream>::value) {
		if(!ds_connect->get_istr()) return false;
		stream = new T(*ds_connect->get_istr());
		return ds->open(stream, NULL, p_streamargs, ds_connect);
	} else if constexpr(std::is_same<S, std::ostream>::value) {
		if(!ds_connect->get_ostr()) return false;
		stream = new T(*ds_connect->get_ostr());
		return ds->open(NULL, stream, p_streamargs, ds_connect);
	} else if constexpr(std::is_same<S, std::iostream>::value) {
		if(!ds_connect->get_iostr()) return false;
		stream = new T(*ds_connect->get_iostr());
		return ds->open(stream, stream, p_streamargs, ds_connect);
	}
	return false;
}
template <class T, class S> datastream* connect_stream_factory(datastream* ds_connect, f_streamargs) {
	datastream* ds = new datastream();
	if(!connect_stream_open<T, S>(ds, ds_connect, p_streamargs)) throw InvalidArgumentException("Unable to attach given stream");
	return ds;
}
template <class T, class S, datastream_factory_type factory> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname) {
	RegisterDatastreamType<T, factory>(engine, classname);
	engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_FACTORY, format("%s@ s(datastream@, const string&in = \"\", int byteorder = 1)", classname).c_str(), asFUNCTION((connect_stream_factory<T, S>)), asCALL_CDECL);
	engine->RegisterObjectMethod(classname.c_str(), "bool open(datastream@, const string&in = \"\", int byteorder = 1)", asFUNCTION((connect_stream_open<T, S>)), asCALL_CDECL_OBJFIRST);
}
template <class T, class S, typename A1> bool connect_stream_open(datastream* ds, datastream* ds_connect, A1 arg1, f_streamargs) {
	if(!ds_connect) return false;
	SharedPtr<S> stream;
	if constexpr(std::is_same<S, std::istream>::value) {
		if(!ds_connect->get_istr()) return false;
		stream = new T(*ds_connect->get_istr(), arg1);
		return ds->open(stream, NULL, p_streamargs, ds_connect);
	} else if constexpr(std::is_same<S, std::ostream>::value) {
		if(!ds_connect->get_ostr()) return false;
		stream = new T(*ds_connect->get_ostr(), arg1);
		return ds->open(NULL, stream, p_streamargs, ds_connect);
	} else if constexpr(std::is_same<S, std::iostream>::value) {
		if(!ds_connect->get_iostr()) return false;
		stream = new T(*ds_connect->get_iostr(), arg1);
		return ds->open(stream, stream, p_streamargs, ds_connect);
	}
	return false;
}
template <class T, class S, typename A1> datastream* connect_stream_factory(datastream* ds_connect, A1 arg1, f_streamargs) {
	datastream* ds = new datastream();
	if(!connect_stream_open<T, S,  A1>(ds, ds_connect, arg1, p_streamargs)) throw InvalidArgumentException("Unable to attach given stream");
	return ds;
}
template <class T, class S, typename A1, datastream_factory_type factory> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname, const std::string& arg_types) {
	RegisterDatastreamType<T, factory>(engine, classname);
	engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_FACTORY, format("%s@ s(datastream@, %s, const string&in = \"\", int byteorder = 1)", classname, arg_types).c_str(), asFUNCTION((connect_stream_factory<T, S, A1>)), asCALL_CDECL);
	engine->RegisterObjectMethod(classname.c_str(), format("bool open(datastream@, %s, const string&in = \"\", int byteorder = 1)", arg_types).c_str(), asFUNCTION((connect_stream_open<T, S, A1>)), asCALL_CDECL_OBJFIRST);
}
template <class T, class S, typename A1, typename A2> bool connect_stream_open(datastream* ds, datastream* ds_connect, A1 arg1, A2 arg2, f_streamargs) {
	if(!ds_connect) return false;
	SharedPtr<S> stream;
	if constexpr(std::is_same<S, std::istream>::value) {
		if(!ds_connect->get_istr()) return false;
		stream = new T(*ds_connect->get_istr(), arg1, arg2);
		return ds->open(stream, NULL, p_streamargs, ds_connect);
	} else if constexpr(std::is_same<S, std::ostream>::value) {
		if(!ds_connect->get_ostr()) return false;
		stream = new T(*ds_connect->get_ostr(), arg1, arg2);
		return ds->open(NULL, stream, p_streamargs, ds_connect);
	} else if constexpr(std::is_same<S, std::iostream>::value) {
		if(!ds_connect->get_iostr()) return false;
		stream = new T(*ds_connect->get_iostr(), arg1, arg2);
		return ds->open(stream, stream, p_streamargs, ds_connect);
	}
	return false;
}
template <class T, class S, typename A1, typename A2> datastream* connect_stream_factory(datastream* ds_connect, A1 arg1, A2 arg2, f_streamargs) {
	datastream* ds = new datastream();
	if(!connect_stream_open<T, S,  A1, A2>(ds, ds_connect, arg1, arg2, p_streamargs)) throw InvalidArgumentException("Unable to attach given stream");
	return ds;
}
template <class T, class S, typename A1, typename A2, datastream_factory_type factory> void RegisterDatastreamType(asIScriptEngine* engine, const std::string& classname, const std::string& arg_types) {
	RegisterDatastreamType<T, factory>(engine, classname);
	engine->RegisterObjectBehaviour(classname.c_str(), asBEHAVE_FACTORY, format("%s@ s(datastream@, %s, const string&in = \"\", int byteorder = 1)", classname, arg_types).c_str(), asFUNCTION((connect_stream_factory<T, S, A1, A2>)), asCALL_CDECL);
	engine->RegisterObjectMethod(classname.c_str(), format("bool open(datastream@, %s, const string&in = \"\", int byteorder = 1)", arg_types).c_str(), asFUNCTION((connect_stream_open<T, S, A1, A2>)), asCALL_CDECL_OBJFIRST);
}

// In regards to additional Angelscript function registration, we shall use asCALL_CDECL_OBJFIRST to avoid actually modifying or deriving from classes.
// FileStream
bool file_stream_open(datastream* ds, const std::string& path, const std::string& mode, f_streamargs) {
	std::ios::openmode m = std::ios::binary;
	for(char c : mode) {
		if(c == 'b') continue;
		else if(c == 'r') m |= std::ios::in;
		else if(c == 'w') m |= std::ios::out | std::ios::trunc;
		else if(c == 'a') m |= std::ios::out | std::ios::app;
		else if(c == '+') m |= std::ios::out | std::ios::ate;
	}
	if((m & std::ios::in) == 0 && (m & std::ios::out) == 0) return false; // invalid mode.
	try {
		iostrPtr iostr = new FileStream(path, m);
		return ds->open((m & std::ios::in) != 0? iostr : NULL, (m & std::ios::out) != 0? iostr : NULL, p_streamargs, NULL);
	} catch(FileException& e) {
		return false; // Todo: get_last_error or similar.
	}
}
datastream* file_stream_factory(const std::string& path , const std::string& mode, f_streamargs) {
	datastream* ds = new datastream();
	file_stream_open(ds, path, mode, p_streamargs);
	return ds;
}
unsigned long long file_stream_size(datastream* ds) {
	FileStream* stream = dynamic_cast<FileStream*>(ds->stream());
	return stream? stream->size() : 0;
}

// stringstream.
bool stringstream_open(datastream* ds, const std::string& initial = "", f_streamargs) {
	iostrPtr iostr = new std::stringstream(initial);
	return ds->open(iostr, iostr, p_streamargs, NULL);
}
datastream* stringstream_factory(const std::string& initial = "", const std::string& encoding = "", int byteorder = BinaryReader::NATIVE_BYTE_ORDER) {
	datastream* ds = new datastream();
	stringstream_open(ds, initial, encoding, byteorder);
	return ds;
}
std::string stringstream_str(datastream* ds) {
	std::stringstream* ss = dynamic_cast<std::stringstream*>(ds->stream());
	return ss? ss->str() : "";
}
// duplicating_reader/writer, in Poco known as TeeStream.
void duplicating_stream_close(datastream* ds) {
	std::vector<datastream*>* streams = (std::vector<datastream*>*)ds->user;
	if(!streams) return;
	for(datastream* s : *streams) s->release();
	streams->clear();
}
datastream* duplicating_stream_add(datastream* ds, datastream* ds_connect) {
	if(!ds_connect) return ds;
	TeeIOS* ios = dynamic_cast<TeeIOS*>(ds->stream());
	if(!ios) throw InvalidArgumentException("not a duplicating reader or writer");
	std::ostream* ostr = ds_connect->get_ostr();
	if(!ostr) throw InvalidArgumentException("non-writer was connected to duplicator");
	std::vector<datastream*>* streams = ds->user? (std::vector<datastream*>*)ds->user : new std::vector<datastream*>;
	streams->push_back(ds_connect);
	ios->addStream(*ostr);
	if(!ds->user) {
		ds->user = streams;
		ds->set_close_callback(duplicating_stream_close);
	}
	ds->duplicate();
	return ds;
}
void RegisterDuplicatingStream(asIScriptEngine* engine) {
	RegisterDatastreamType<TeeInputStream, std::istream>(engine, "duplicating_reader");
	engine->RegisterObjectMethod("duplicating_reader", "duplicating_reader@ opAdd(datastream@)", asFUNCTION(duplicating_stream_add), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("duplicating_reader", "duplicating_reader@ opAddAssign(datastream@)", asFUNCTION(duplicating_stream_add), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("duplicating_reader", "duplicating_reader@ add(datastream@)", asFUNCTION(duplicating_stream_add), asCALL_CDECL_OBJFIRST);
	RegisterDatastreamType<TeeOutputStream, std::ostream, datastream_factory_opened>(engine, "duplicating_writer");
	engine->RegisterObjectMethod("duplicating_writer", "duplicating_writer@ opAdd(datastream@)", asFUNCTION(duplicating_stream_add), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("duplicating_writer", "duplicating_writer@ opAddAssign(datastream@)", asFUNCTION(duplicating_stream_add), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("duplicating_writer", "duplicating_writer@ add(datastream@)", asFUNCTION(duplicating_stream_add), asCALL_CDECL_OBJFIRST);
}

// counting streams
std::streamsize counting_stream_chars(datastream* ds) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); return ios? ios->chars() : -1; }
std::streamsize counting_stream_lines(datastream* ds) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); return ios? ios->lines() : -1; }
std::streamsize counting_stream_pos(datastream* ds) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); return ios? ios->pos() : -1; }
std::streamsize counting_stream_get_current_line(datastream* ds) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); return ios? ios->getCurrentLineNumber() : -1; }
void counting_stream_reset(datastream* ds) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); if(ios) ios->reset(); }
void counting_stream_set_current_line(datastream* ds, std::streamsize value) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); if(ios) ios->setCurrentLineNumber(value); }
void counting_stream_add_chars(datastream* ds, std::streamsize value) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); if(ios) ios->addChars(value); }
void counting_stream_add_lines(datastream* ds, std::streamsize value) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); if(ios) ios->addLines(value); }
void counting_stream_add_pos(datastream* ds, std::streamsize value) { CountingIOS* ios = dynamic_cast<CountingIOS*>(ds->stream()); if(ios) ios->addPos(value); }
template <class T, class S> void RegisterCountingStream(asIScriptEngine* engine, const std::string& type) {
	RegisterDatastreamType<T, S>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "int64 get_chars() property", asFUNCTION(counting_stream_chars), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "int64 get_lines() property", asFUNCTION(counting_stream_lines), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "int64 get_current_line() property", asFUNCTION(counting_stream_get_current_line), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void reset()", asFUNCTION(counting_stream_reset), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_current_line(int64)", asFUNCTION(counting_stream_set_current_line), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void add_chars(int64)", asFUNCTION(counting_stream_add_chars), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void add_lines(int64)", asFUNCTION(counting_stream_add_lines), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void add_pos(int64)", asFUNCTION(counting_stream_add_pos), asCALL_CDECL_OBJFIRST);
}
// PartialInputStream, known to nvgt as partial_reader.
bool partial_reader_open(datastream* ds, datastream* ds_connect, unsigned long long start, unsigned long long end, bool initialize, const std::string& prefix, const std::string& postfix, f_streamargs) {
	if(!ds_connect) return false;
	std::istream* istr = ds_connect->get_istr();
	if(!istr) return false;
	return ds->open(new Zip::PartialInputStream(*istr, start, end, initialize, prefix, postfix), NULL, p_streamargs, ds_connect);
}
datastream* partial_reader_factory(datastream* ds_connect, unsigned long long start, unsigned long long end, bool initialize, const std::string& prefix, const std::string& postfix, f_streamargs) {
	datastream* ds = new datastream();
	partial_reader_open(ds, ds_connect, start, end, initialize, prefix, postfix, p_streamargs);
	return ds;
}

// Wrappers around cin, cout and cerr from the stl. The first function just performs any common setup used for all 3 streams.
datastream* dscmd(datastream* ds) {
	ds->no_close = true;
	ds->binary = false;
	return ds;
}
//Todo: evaluate for sure whether these streams are being destroyed in the correct manner on application exit. This is low priority because the operating system should clean up for us on exit and there is no way for this to produce a serious memory leak if it does at all, but if we run into any issues, check here.
datastream* get_cin() {
	if(!ds_cin) ds_cin = dscmd(new datastream(&std::cin));
	ds_cin->duplicate();
	return ds_cin;
}
datastream* get_cout() {
	if(!ds_cout) ds_cout = dscmd(new datastream(&std::cout));
	ds_cout->duplicate();
	return ds_cout;
}
datastream* get_cerr() {
	if(!ds_cerr) ds_cerr = dscmd(new datastream(&std::cerr));
	ds_cerr->duplicate();
	return ds_cerr;
}

void RegisterScriptDatastreams(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterEnum("compression_method");
	engine->RegisterEnumValue("compression_method", "COMPRESSION_METHOD_ZLIB", DeflatingStreamBuf::STREAM_ZLIB);
	engine->RegisterEnumValue("compression_method", "COMPRESSION_METHOD_GZIP", DeflatingStreamBuf::STREAM_GZIP);
	engine->SetDefaultNamespace("spec");
	engine->RegisterGlobalProperty("const string NEWLINE_DEFAULT", (void*)&LineEnding::NEWLINE_DEFAULT);
	engine->RegisterGlobalProperty("const string NEWLINE_CR", (void*)&LineEnding::NEWLINE_CR);
	engine->RegisterGlobalProperty("const string NEWLINE_CRLF", (void*)&LineEnding::NEWLINE_CRLF);
	engine->RegisterGlobalProperty("const string NEWLINE_LF", (void*)&LineEnding::NEWLINE_LF);
	engine->SetDefaultNamespace("");
	RegisterDatastreamType<std::stringstream, datastream_factory_none>(engine, "datastream");
	engine->RegisterObjectBehaviour("datastream", asBEHAVE_FACTORY, "datastream@ d(const string&in = \"\", const string&in encoding = \"\", int byteorder = 1)", asFUNCTION(stringstream_factory), asCALL_CDECL);
	engine->RegisterObjectMethod("datastream", "bool open(const string&in = \"\", const string&in encoding = \"\", int byteorder = 1)", asFUNCTION(stringstream_open), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("datastream", "string str()", asFUNCTION(stringstream_str), asCALL_CDECL_OBJFIRST);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_TERMINAL);
	engine->RegisterGlobalFunction("datastream@ get_cin() property", asFUNCTION(get_cin), asCALL_CDECL);
	engine->RegisterGlobalFunction("datastream@ get_cout() property", asFUNCTION(get_cout), asCALL_CDECL);
	engine->RegisterGlobalFunction("datastream@ get_cerr() property", asFUNCTION(get_cerr), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_FS);
	RegisterDatastreamType<FileStream, datastream_factory_closed>(engine, "file");
	engine->RegisterObjectBehaviour("file", asBEHAVE_FACTORY, "file@ d(const string&in, const string&in, const string&in = \"\", int byteorder = 1)", asFUNCTION(file_stream_factory), asCALL_CDECL);
	engine->RegisterObjectMethod("file", "bool open(const string&in, const string&in, const string&in = \"\", int byteorder = 1)", asFUNCTION(file_stream_open), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("file", "uint64 get_size() const property", asFUNCTION(file_stream_size), asCALL_CDECL_OBJFIRST);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	RegisterDatastreamType<Zip::PartialInputStream, datastream_factory_closed>(engine, "partial_reader");
	engine->RegisterObjectBehaviour("partial_reader", asBEHAVE_FACTORY, "partial_reader@ d(datastream@, uint64, uint64, bool = true, const string&in = \"\", const string&in = \"\", const string&in encoding = \"\", int byteorder = 1)", asFUNCTION(partial_reader_factory), asCALL_CDECL);
	engine->RegisterObjectMethod("partial_reader", "bool open(datastream@, uint64, uint64, bool = true, const string&in = \"\", const string&in = \"\", const string&in encoding = \"\", int byteorder = 1)", asFUNCTION(partial_reader_open), asCALL_CDECL_OBJFIRST);
	RegisterDatastreamType<HexBinaryDecoder, std::istream>(engine, "hex_decoder");
	RegisterDatastreamType<HexBinaryEncoder, std::ostream>(engine, "hex_encoder");
	RegisterDatastreamType<Base32Decoder, std::istream>(engine, "base32_decoder");
	RegisterDatastreamType<Base32Encoder, std::ostream, bool>(engine, "base32_encoder", "bool padding = true");
	RegisterDatastreamType<Base64Decoder, std::istream, int>(engine, "base64_decoder", "int options = 0");
	RegisterDatastreamType<Base64Encoder, std::ostream, int>(engine, "base64_encoder", "int options = 0");
	RegisterDatastreamType<RandomInputStream>(engine, "random_reader");
	RegisterDatastreamType<NullOutputStream>(engine, "discarding_writer");
	RegisterDuplicatingStream(engine);
	RegisterDatastreamType<DeflatingInputStream, std::istream, DeflatingStreamBuf::StreamType, int>(engine, "deflating_reader", "compression_method compression = COMPRESSION_METHOD_ZLIB, int level = 9");
	RegisterDatastreamType<DeflatingOutputStream, std::ostream, DeflatingStreamBuf::StreamType, int>(engine, "deflating_writer", "compression_method compression = COMPRESSION_METHOD_ZLIB, int level = 9");
	RegisterDatastreamType<InflatingInputStream, std::istream, InflatingStreamBuf::StreamType>(engine, "inflating_reader", "compression_method compression = COMPRESSION_METHOD_ZLIB");
	RegisterDatastreamType<InflatingOutputStream, std::ostream, InflatingStreamBuf::StreamType>(engine, "inflating_writer", "compression_method compression = COMPRESSION_METHOD_ZLIB");
	RegisterCountingStream<CountingInputStream, std::istream>(engine, "counting_reader");
	RegisterCountingStream<CountingOutputStream, std::ostream>(engine, "counting_writer");
	RegisterDatastreamType<InputLineEndingConverter, std::istream, const std::string&>(engine, "line_converting_reader", "const string&in line_ending = spec::NEWLINE_DEFAULT");
	RegisterDatastreamType<OutputLineEndingConverter, std::ostream, const std::string&>(engine, "line_converting_writer", "const string&in line_ending = spec::NEWLINE_DEFAULT");
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
}
