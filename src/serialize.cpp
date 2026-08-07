/* serialize.cpp - code for data serialization routines
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2026 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

// Protocol format: the first 4 bytes are a magic header. Dictionaries serialized by old versions of NVGT begin with \x0e\x16\x07\x14 and are still readable by deserialize() below (see deserialize_legacy). Anything written from now on begins with "\x0e\x16\x07\x04" followed by 4 reserved bytes (currently zero, reserved for a future format revision number) and is read/written using the tagged value_tag format implemented in this file.

#include <cstdint>
#include <cstring>
#include <functional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>
#include <angelscript.h>
#include <Poco/BinaryReader.h>
#include <Poco/BinaryWriter.h>
#include <Poco/MemoryStream.h>
#include <Poco/JSON/Parser.h>
#include <Poco/Net/NameValueCollection.h>
#include <scriptarray.h>
#include <scriptdictionary.h>
#include "nvgt.h"
#include "pocostuff.h"
#include "serialize.h"

int g_StringTypeid = 0;
static int g_DictionaryTypeId = 0;
static int string_type_id() {
	if (!g_StringTypeid) g_StringTypeid = g_ScriptEngine->GetStringFactory();
	return g_StringTypeid;
}
static int dictionary_type_id() {
	if (!g_DictionaryTypeId) g_DictionaryTypeId = g_ScriptEngine->GetTypeInfoByName("dictionary")->GetTypeId();
	return g_DictionaryTypeId;
}
static int dictionary_handle_type_id() { return dictionary_type_id() | asTYPEID_OBJHANDLE; }
// The module of whatever script function is currently calling into us, needed to resolve array element types and user script classes by name/declaration when deserializing.
static asIScriptModule* current_module() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptFunction* func = ctx ? ctx->GetFunction(0) : nullptr;
	return func ? func->GetModule() : nullptr;
}

// Every value we know how to (de)serialize is prefixed with one of these tags. Add a new entry plus a branch in write_value/read_value below to teach serialize() about another type.
enum class value_tag : unsigned char {
	boolean = 1, int8, uint8, int16, uint16, int32, uint32, int64, uint64, float32, float64,
	string, dictionary, array, pod, json_object, json_array, name_value_collection, script_object
};

// Runs a registered/script function (which must return an object handle) through a pooled context. Only needed for the script_object contract below, everything else we can talk to directly in c++.
static void* invoke(asIScriptFunction* func, void* obj, void* arg = nullptr) {
	if (!func) return nullptr;
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return nullptr;
	void* result = nullptr;
	if (ctx->Prepare(func) >= 0) {
		if (obj) ctx->SetObject(obj);
		if (arg) ctx->SetArgObject(0, arg);
		if (ctx->Execute() == asEXECUTION_FINISHED) {
			result = ctx->GetReturnObject();
			if (result) g_ScriptEngine->AddRefScriptObject(result, g_ScriptEngine->GetTypeInfoById(func->GetReturnTypeId()));
		}
	}
	g_ScriptEngine->ReturnContext(ctx);
	return result;
}
// Locates a factory (constructor) taking exactly one dictionary@ argument, and a 0 argument method called opCast returning dictionary@; together these let a script class opt into serialization support.
static asIScriptFunction* find_dictionary_factory(asITypeInfo* ti) {
	const int want = dictionary_handle_type_id();
	for (asUINT i = 0; i < ti->GetFactoryCount(); i++) {
		asIScriptFunction* f = ti->GetFactoryByIndex(i);
		int pt = 0;
		if (f->GetParamCount() == 1 && f->GetParam(0, &pt) >= 0 && pt == want) return f;
	}
	return nullptr;
}
static asIScriptFunction* find_dictionary_opcast(asITypeInfo* ti) {
	const int want = dictionary_handle_type_id();
	for (asUINT i = 0; i < ti->GetMethodCount(); i++) {
		asIScriptFunction* f = ti->GetMethodByIndex(i);
		if (!strcmp(f->GetName(), "opCast") && f->GetParamCount() == 0 && f->GetReturnTypeId() == want) return f;
	}
	return nullptr;
}

static bool write_value(Poco::BinaryWriter& w, const void* ref, int type_id);
static bool try_write_value(const void* ref, int type_id, std::string& out) {
	std::ostringstream ss;
	Poco::BinaryWriter w(ss);
	if (!write_value(w, ref, type_id)) return false;
	out = ss.str();
	return true;
}
// A dictionary's contents are just however many (key, serialized value) pairs made it through try_write_value; keys whose value can't be serialized are silently dropped.
static void write_dictionary_body(Poco::BinaryWriter& w, CScriptDictionary* dict) {
	std::vector<std::pair<std::string, std::string>> entries;
	for (CScriptDictionary::CIterator it = dict->begin(); it != dict->end(); it++) {
		std::string bytes;
		if (try_write_value(it.GetAddressOfValue(), it.GetTypeId(), bytes))
			entries.emplace_back(it.GetKey(), std::move(bytes));
	}
	w << (Poco::UInt32)entries.size();
	for (auto& e : entries) {
		w << e.first;
		w.writeRaw(e.second);
	}
}
// Arrays are homogeneous, so unlike dictionary keys we can't drop individual elements; if any element fails the whole array is unsupported and the caller drops it instead.
static bool write_array_body(Poco::BinaryWriter& w, CScriptArray* arr) {
	int elem_type = arr->GetElementTypeId();
	asUINT count = arr->GetSize();
	std::vector<std::string> elems(count);
	for (asUINT i = 0; i < count; i++) {
		if (!try_write_value(arr->At(i), elem_type, elems[i])) return false;
	}
	w << (Poco::UInt32)count;
	for (auto& e : elems) w.writeRaw(e);
	return true;
}
static bool write_script_object(Poco::BinaryWriter& w, void* obj, asITypeInfo* ti, bool is_null) {
	asIScriptFunction* factory = find_dictionary_factory(ti);
	asIScriptFunction* opcast = find_dictionary_opcast(ti);
	if (!factory || !opcast) return false;
	w << (unsigned char)value_tag::script_object;
	w << std::string(ti->GetName());
	w << is_null;
	if (is_null) return true;
	CScriptDictionary* d = (CScriptDictionary*)invoke(opcast, obj);
	if (!d) return false;
	write_dictionary_body(w, d);
	d->Release();
	return true;
}
static bool write_value(Poco::BinaryWriter& w, const void* ref, int type_id) {
	switch (type_id) {
		case asTYPEID_BOOL: w << (unsigned char)value_tag::boolean; w << *(bool*)ref; return true;
		case asTYPEID_INT8: w << (unsigned char)value_tag::int8; w << *(int8_t*)ref; return true;
		case asTYPEID_UINT8: w << (unsigned char)value_tag::uint8; w << *(uint8_t*)ref; return true;
		case asTYPEID_INT16: w << (unsigned char)value_tag::int16; w << *(int16_t*)ref; return true;
		case asTYPEID_UINT16: w << (unsigned char)value_tag::uint16; w << *(uint16_t*)ref; return true;
		case asTYPEID_INT32: w << (unsigned char)value_tag::int32; w << *(int32_t*)ref; return true;
		case asTYPEID_UINT32: w << (unsigned char)value_tag::uint32; w << *(uint32_t*)ref; return true;
		case asTYPEID_INT64: w << (unsigned char)value_tag::int64; w << *(int64_t*)ref; return true;
		case asTYPEID_UINT64: w << (unsigned char)value_tag::uint64; w << *(uint64_t*)ref; return true;
		case asTYPEID_FLOAT: w << (unsigned char)value_tag::float32; w << *(float*)ref; return true;
		case asTYPEID_DOUBLE: w << (unsigned char)value_tag::float64; w << *(double*)ref; return true;
		default: break;
	}
	if (type_id == string_type_id()) {
		w << (unsigned char)value_tag::string;
		w << *(std::string*)ref;
		return true;
	}
	// Enums and any other type angelscript considers primitive-sized fall back to a raw byte copy keyed on their declaration, the same mechanism used for POD value types like vector below.
	int prim_size = g_ScriptEngine->GetSizeOfPrimitiveType(type_id);
	if (prim_size > 0) {
		w << (unsigned char)value_tag::pod;
		w << std::string(g_ScriptEngine->GetTypeDeclaration(type_id, false));
		w << (Poco::UInt32)prim_size;
		w.writeRaw((const char*)ref, prim_size);
		return true;
	}
	if (!(type_id & asTYPEID_MASK_OBJECT)) return false;
	bool is_handle = type_id & asTYPEID_OBJHANDLE;
	void* obj = is_handle ? *(void**)ref : const_cast<void*>(ref);
	bool is_null = is_handle && !obj;
	asITypeInfo* ti = g_ScriptEngine->GetTypeInfoById(type_id);
	if (!ti) return false;
	const char* name = ti->GetName();
	if (!strcmp(name, "dictionary")) {
		w << (unsigned char)value_tag::dictionary;
		w << is_null;
		if (!is_null) write_dictionary_body(w, (CScriptDictionary*)obj);
		return true;
	}
	if (!strcmp(name, "array")) {
		w << (unsigned char)value_tag::array;
		w << std::string(g_ScriptEngine->GetTypeDeclaration(ti->GetSubTypeId(0), false));
		w << is_null;
		return is_null ? true : write_array_body(w, (CScriptArray*)obj);
	}
	if (!strcmp(name, "json_object")) {
		w << (unsigned char)value_tag::json_object;
		w << is_null;
		if (!is_null) w << ((poco_json_object*)obj)->stringify();
		return true;
	}
	if (!strcmp(name, "json_array")) {
		w << (unsigned char)value_tag::json_array;
		w << is_null;
		if (!is_null) w << ((poco_json_array*)obj)->stringify();
		return true;
	}
	if (!strcmp(name, "name_value_collection")) {
		w << (unsigned char)value_tag::name_value_collection;
		w << is_null;
		if (!is_null) {
			Poco::Net::NameValueCollection* nvc = (Poco::Net::NameValueCollection*)obj;
			w << (Poco::UInt32)nvc->size();
			for (const auto& kv : *nvc) {
				w << kv.first;
				w << kv.second;
			}
		}
		return true;
	}
	if (type_id & asTYPEID_SCRIPTOBJECT) return write_script_object(w, obj, ti, is_null);
	if ((ti->GetFlags() & asOBJ_POD) && !is_handle) {
		asUINT size = ti->GetSize();
		w << (unsigned char)value_tag::pod;
		w << std::string(g_ScriptEngine->GetTypeDeclaration(type_id, false));
		w << (Poco::UInt32)size;
		w.writeRaw((const char*)ref, size);
		return true;
	}
	return false; // Unsupported type, the caller (a dictionary key or array element) drops it.
}

// Invoked with the raw value/type produced by read_value; implemented differently by dictionary and array bodies since CScriptDictionary::Set needs an explicit type id while CScriptArray::SetValue infers it from the array's own element type.
using value_setter = std::function<void(void*, int)>;

static CScriptDictionary* read_dictionary_body(Poco::BinaryReader& r, asIScriptModule* mod);
static void read_array_body(Poco::BinaryReader& r, asIScriptModule* mod, CScriptArray* arr);
static void read_value(Poco::BinaryReader& r, asIScriptModule* mod, const value_setter& set) {
	unsigned char tag;
	r >> tag;
	switch ((value_tag)tag) {
		case value_tag::boolean: { bool v; r >> v; set(&v, asTYPEID_BOOL); return; }
		case value_tag::int8: { int8_t v; r >> v; set(&v, asTYPEID_INT8); return; }
		case value_tag::uint8: { uint8_t v; r >> v; set(&v, asTYPEID_UINT8); return; }
		case value_tag::int16: { int16_t v; r >> v; set(&v, asTYPEID_INT16); return; }
		case value_tag::uint16: { uint16_t v; r >> v; set(&v, asTYPEID_UINT16); return; }
		case value_tag::int32: { int32_t v; r >> v; set(&v, asTYPEID_INT32); return; }
		case value_tag::uint32: { uint32_t v; r >> v; set(&v, asTYPEID_UINT32); return; }
		case value_tag::int64: { int64_t v; r >> v; set(&v, asTYPEID_INT64); return; }
		case value_tag::uint64: { uint64_t v; r >> v; set(&v, asTYPEID_UINT64); return; }
		case value_tag::float32: { float v; r >> v; set(&v, asTYPEID_FLOAT); return; }
		case value_tag::float64: { double v; r >> v; set(&v, asTYPEID_DOUBLE); return; }
		case value_tag::string: { std::string v; r >> v; set(&v, string_type_id()); return; }
		case value_tag::pod: {
			std::string decl;
			r >> decl;
			Poco::UInt32 size = 0;
			r >> size;
			std::string bytes;
			r.readRaw(size, bytes);
			asITypeInfo* ti = mod ? mod->GetTypeInfoByDecl(decl.c_str()) : nullptr;
			if (ti && (asUINT)ti->GetSize() == size) set((void*)bytes.data(), ti->GetTypeId());
			return;
		}
		case value_tag::dictionary: {
			bool is_null;
			r >> is_null;
			int tid = dictionary_handle_type_id();
			if (is_null) { void* n = nullptr; set(&n, tid); return; }
			CScriptDictionary* d = read_dictionary_body(r, mod);
			set(&d, tid);
			d->Release();
			return;
		}
		case value_tag::array: {
			std::string elem_decl;
			r >> elem_decl;
			bool is_null;
			r >> is_null;
			asITypeInfo* arr_ti = mod ? mod->GetTypeInfoByDecl(("array<" + elem_decl + ">").c_str()) : nullptr;
			if (is_null) {
				if (arr_ti) { void* n = nullptr; int tid = arr_ti->GetTypeId() | asTYPEID_OBJHANDLE; set(&n, tid); }
				return;
			}
			CScriptArray* arr = arr_ti ? CScriptArray::Create(arr_ti) : nullptr;
			read_array_body(r, mod, arr);
			if (arr) {
				int tid = arr_ti->GetTypeId() | asTYPEID_OBJHANDLE;
				set(&arr, tid);
				arr->Release();
			}
			return;
		}
		case value_tag::json_object: {
			bool is_null;
			r >> is_null;
			asITypeInfo* ti = g_ScriptEngine->GetTypeInfoByName("json_object");
			if (is_null) { if (ti) { void* n = nullptr; int tid = ti->GetTypeId() | asTYPEID_OBJHANDLE; set(&n, tid); } return; }
			std::string text;
			r >> text;
			Poco::JSON::Parser parser;
			poco_json_object* obj = new poco_json_object(parser.parse(text).extract<Poco::JSON::Object::Ptr>());
			if (ti) { void* p = obj; set(&p, ti->GetTypeId() | asTYPEID_OBJHANDLE); }
			obj->release();
			return;
		}
		case value_tag::json_array: {
			bool is_null;
			r >> is_null;
			asITypeInfo* ti = g_ScriptEngine->GetTypeInfoByName("json_array");
			if (is_null) { if (ti) { void* n = nullptr; int tid = ti->GetTypeId() | asTYPEID_OBJHANDLE; set(&n, tid); } return; }
			std::string text;
			r >> text;
			Poco::JSON::Parser parser;
			poco_json_array* obj = new poco_json_array(parser.parse(text).extract<Poco::JSON::Array::Ptr>());
			if (ti) { void* p = obj; set(&p, ti->GetTypeId() | asTYPEID_OBJHANDLE); }
			obj->release();
			return;
		}
		case value_tag::name_value_collection: {
			bool is_null;
			r >> is_null;
			asITypeInfo* ti = g_ScriptEngine->GetTypeInfoByName("name_value_collection");
			if (is_null) { if (ti) { void* n = nullptr; int tid = ti->GetTypeId() | asTYPEID_OBJHANDLE; set(&n, tid); } return; }
			Poco::UInt32 count = 0;
			r >> count;
			Poco::Net::NameValueCollection* nvc = new (angelscript_refcounted_create<Poco::Net::NameValueCollection>()) Poco::Net::NameValueCollection();
			for (Poco::UInt32 i = 0; i < count; i++) {
				std::string name, value;
				r >> name;
				r >> value;
				nvc->add(name, value);
			}
			if (ti) { void* p = nvc; set(&p, ti->GetTypeId() | asTYPEID_OBJHANDLE); }
			angelscript_refcounted_release<Poco::Net::NameValueCollection>(nvc);
			return;
		}
		case value_tag::script_object: {
			std::string class_name;
			r >> class_name;
			bool is_null;
			r >> is_null;
			asITypeInfo* ti = mod ? mod->GetTypeInfoByName(class_name.c_str()) : nullptr;
			if (is_null) {
				if (ti) { void* n = nullptr; int tid = ti->GetTypeId() | asTYPEID_OBJHANDLE; set(&n, tid); }
				return;
			}
			CScriptDictionary* d = read_dictionary_body(r, mod); // Always parseable regardless of whether the class still exists, since it's just our own dictionary format.
			asIScriptFunction* factory = ti ? find_dictionary_factory(ti) : nullptr;
			if (factory) {
				void* obj = invoke(factory, nullptr, d);
				if (obj) {
					int tid = ti->GetTypeId() | asTYPEID_OBJHANDLE;
					set(&obj, tid);
					g_ScriptEngine->ReleaseScriptObject(obj, ti);
				}
			}
			d->Release();
			return;
		}
		default: throw std::runtime_error("corrupt serialized data");
	}
}
static CScriptDictionary* read_dictionary_body(Poco::BinaryReader& r, asIScriptModule* mod) {
	CScriptDictionary* dict = CScriptDictionary::Create(g_ScriptEngine);
	Poco::UInt32 count = 0;
	r >> count;
	for (Poco::UInt32 i = 0; i < count; i++) {
		std::string key;
		r >> key;
		read_value(r, mod, [&](void* v, int t) { dict->Set(key, v, t); });
	}
	return dict;
}
static void read_array_body(Poco::BinaryReader& r, asIScriptModule* mod, CScriptArray* arr) {
	Poco::UInt32 count = 0;
	r >> count;
	if (arr) arr->Resize(count);
	for (Poco::UInt32 i = 0; i < count; i++)
		read_value(r, mod, [&](void* v, int) { if (arr) arr->SetValue(i, v); });
}

// Cleaned up but format-compatible reimplementation of the pre-2025 dictionary format (bool/int64/double/string only, keyed on a 1 byte type tag). Bounds every read against the remaining buffer instead of trusting embedded lengths, since that trust is what made the original implementation crash-prone on truncated or malformed input.
static CScriptDictionary* deserialize_legacy(const std::string& input) {
	CScriptDictionary* dict = CScriptDictionary::Create(g_ScriptEngine);
	size_t pos = 4; // The 4 byte legacy magic was already matched by the caller.
	auto fits = [&](size_t n) { return pos + n <= input.size(); };
	if (!fits(4)) return dict;
	Poco::UInt32 count = 0;
	memcpy(&count, input.data() + pos, 4);
	pos += 4;
	for (Poco::UInt32 i = 0; i < count; i++) {
		if (!fits(2)) break;
		uint16_t keylen = 0;
		memcpy(&keylen, input.data() + pos, 2);
		pos += 2;
		if (!fits(keylen)) break;
		std::string key(input.data() + pos, keylen);
		pos += keylen;
		if (!fits(1)) break;
		unsigned char type = (unsigned char)input[pos++];
		if (type < 1 || type > 4) break;
		if (type == 1) {
			if (!fits(1)) break;
			bool val = input[pos++] != 0;
			dict->Set(key, &val, asTYPEID_BOOL);
		} else if (type == 2) {
			if (!fits(8)) break;
			asINT64 val = 0;
			memcpy(&val, input.data() + pos, 8);
			pos += 8;
			dict->Set(key, val);
		} else if (type == 3) {
			if (!fits(8)) break;
			double val = 0;
			memcpy(&val, input.data() + pos, 8);
			pos += 8;
			dict->Set(key, val);
		} else if (type == 4) {
			if (!fits(4)) break;
			Poco::UInt32 len = 0;
			memcpy(&len, input.data() + pos, 4);
			pos += 4;
			if (!fits(len)) break;
			std::string val(input.data() + pos, len);
			pos += len;
			dict->Set(key, &val, string_type_id());
		}
	}
	return dict;
}

static const char LEGACY_MAGIC[4] = {'\x0e', '\x16', '\x07', '\x14'};
static const char CURRENT_HEADER[8] = {'\x0e', '\x16', '\x07', '\x04', 0, 0, 0, 0};

std::string serialize(CScriptDictionary& dict) {
	if (dict.GetSize() < 1) return "";
	std::ostringstream ss;
	ss.write(CURRENT_HEADER, sizeof(CURRENT_HEADER));
	Poco::BinaryWriter w(ss);
	write_dictionary_body(w, &dict);
	return ss.str();
}
CScriptDictionary* deserialize(const std::string& input) {
	if (input.size() >= 4 && !memcmp(input.data(), LEGACY_MAGIC, 4)) return deserialize_legacy(input);
	if (input.size() < sizeof(CURRENT_HEADER) || memcmp(input.data(), CURRENT_HEADER, 4) != 0) return CScriptDictionary::Create(g_ScriptEngine);
	Poco::MemoryInputStream ms(input.data() + sizeof(CURRENT_HEADER), input.size() - sizeof(CURRENT_HEADER));
	Poco::BinaryReader r(ms);
	r.setExceptions();
	return read_dictionary_body(r, current_module());
}

void RegisterSerializationFunctions(asIScriptEngine* engine) {
	engine->RegisterObjectMethod("dictionary", "string serialize()", asFUNCTION(serialize), asCALL_CDECL_OBJLAST);
	engine->RegisterGlobalFunction("dictionary@ deserialize(const string& in)", asFUNCTION(deserialize), asCALL_CDECL);
}
