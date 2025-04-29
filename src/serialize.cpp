/* serialize.cpp - code for data serialization routines
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

// I keep forgetting. When it's time to add new serialization format, the first new header should be 0xnvgt0000. Now when deserializing, if the 4 bytes after 0xnvgt are not 0, use the old deserialization method, else read the new key count starting at the 9th byte in the serialized string. Perhaps later when no old dictionaries remain we can then either make the header 4 bytes rather than 8 again, or find a use for the zeroed 4 bytes.

#include <sstream>
#include <cstring>
#include <string>
#include <angelscript.h>
#include <cmp.h>
#include <scriptany.h>
#include <scriptarray.h>
#include <scriptdictionary.h>
#include "nvgt.h"
#include "serialize.h"

int g_StringTypeid = 0;

typedef struct {
	std::string* data;
	unsigned int read_cursor;
} cmp_buffer;
bool cmp_read_bytes(cmp_ctx_t* ctx, void* output, size_t len) {
	cmp_buffer* buf = (cmp_buffer*)ctx->buf;
	if (!buf || !buf->data) return false;
	if (buf->read_cursor + len > buf->data->size()) len = buf->data->size() - buf->read_cursor;
	if (!len) return false;
	memcpy(output, buf->data->data() + buf->read_cursor, len);
	buf->read_cursor += len;
	return true;
}
bool cmp_skip_bytes(cmp_ctx_t* ctx, size_t len) {
	cmp_buffer* buf = (cmp_buffer*)ctx->buf;
	if (!buf || !buf->data) return false;
	if (buf->read_cursor + len > buf->data->size()) len = buf->data->size() - buf->read_cursor;
	if (!len) return false;
	buf->read_cursor += len;
	return true;
}
size_t cmp_write_bytes(cmp_ctx_t* ctx, const void* input, size_t len) {
	cmp_buffer* buf = (cmp_buffer*)ctx->buf;
	if (!buf || !buf->data) return 0;
	buf->data->append((char*)input, len);
	return len;
}

bool serialize_value(const void* value, int type_id, cmp_ctx_t* ctx) {
	if (!g_StringTypeid)
		g_StringTypeid = g_ScriptEngine->GetStringFactory();
	if (type_id == asTYPEID_BOOL) return cmp_write_bool(ctx, *(bool*)value);
	else if (type_id == asTYPEID_INT8) return cmp_write_integer(ctx, *(int8_t*)value);
	else if (type_id == asTYPEID_UINT8) return cmp_write_uinteger(ctx, *(uint8_t*)value);
	else if (type_id == asTYPEID_INT16) return cmp_write_integer(ctx, *(short*)value);
	else if (type_id == asTYPEID_UINT16) return cmp_write_uinteger(ctx, *(unsigned short*)value);
	else if (type_id == asTYPEID_INT32) return cmp_write_integer(ctx, *(int*)value);
	else if (type_id == asTYPEID_UINT32) return cmp_write_uinteger(ctx, *(unsigned int*)value);
	else if (type_id == asTYPEID_INT64) return cmp_write_integer(ctx, *(int64_t*)value);
	else if (type_id == asTYPEID_UINT64) return cmp_write_uinteger(ctx, *(uint64_t*)value);
	else if (type_id == asTYPEID_FLOAT) return cmp_write_decimal(ctx, *(float*)value);
	else if (type_id == asTYPEID_DOUBLE) return cmp_write_decimal(ctx, *(double*)value);
	else if (type_id == g_StringTypeid) {
		std::string* valStr = (std::string*)value;
		asUINT strsize = valStr->size();
		return cmp_write_str(ctx, valStr->c_str(), strsize);
	}
	asITypeInfo* type_info = g_ScriptEngine->GetTypeInfoById(type_id);
	if (!type_info) return false;
	if (strcmp(type_info->GetName(), "dictionary") == 0) {
		CScriptDictionary* dict;
		if (type_id & asTYPEID_OBJHANDLE)
			dict = *(CScriptDictionary**)value;
		else
			dict = (CScriptDictionary*)value;
		if (!cmp_write_map(ctx, dict->GetSize())) return false;
		for (CScriptDictionary::CIterator it = dict->begin(); it != dict->end(); it++) {
			const std::string& key = it.GetKey();
			cmp_write_str(ctx, key.c_str(), key.size());
			if (!serialize_value(it.GetAddressOfValue(), it.GetTypeId(), ctx))
				cmp_write_nil(ctx);
		}
		return true;
	} else if (strcmp(type_info->GetName(), "array") == 0) {
		CScriptArray* array;
		if (type_id & asTYPEID_OBJHANDLE)
			array = *(CScriptArray**)value;
		else
			array = (CScriptArray*)value;
		if (!cmp_write_array(ctx, array->GetSize())) return false;
		for (int i = 0; i < array->GetSize(); i++) {
			if (!serialize_value(array->At(i), array->GetElementTypeId(), ctx)) cmp_write_nil(ctx);
		}
		return true;
	}
	return false;
}
bool deserialize_value(void* value, int type_id, cmp_ctx_t* ctx, cmp_object_t* obj = NULL) {
	cmp_object_t default_obj;
	if (!g_StringTypeid)
		g_StringTypeid = g_ScriptEngine->GetStringFactory();
	if (!obj) {
		obj = &default_obj;
		if (!cmp_read_object(ctx, obj)) return false;
	}
	if (type_id == asTYPEID_BOOL) return cmp_object_as_bool(obj, (bool*)value);
	else if (type_id == asTYPEID_INT8) return cmp_object_as_char(obj, (int8_t*)value);
	else if (type_id == asTYPEID_UINT8) return cmp_object_as_uchar(obj, (uint8_t*)value);
	else if (type_id == asTYPEID_INT16) return cmp_object_as_short(obj, (int16_t*)value);
	else if (type_id == asTYPEID_UINT16) return cmp_object_as_ushort(obj, (uint16_t*)value);
	else if (type_id == asTYPEID_INT32) return cmp_object_as_int(obj, (int32_t*)value);
	else if (type_id == asTYPEID_UINT32) return cmp_object_as_uint(obj, (uint32_t*)value);
	else if (type_id == asTYPEID_INT64) return cmp_object_as_long(obj, (int64_t*)value);
	else if (type_id == asTYPEID_UINT64) return cmp_object_as_ulong(obj, (uint64_t*)value);
	else if (type_id == asTYPEID_DOUBLE) {
		if (cmp_object_as_double(obj, (double*)value)) return true;
		float tmp;
		if (!cmp_object_as_float(obj, &tmp)) return false;
		(*(double*)value) = tmp;
		return true;
	} else if (type_id == asTYPEID_FLOAT) {
		if (cmp_object_as_float(obj, (float*)value)) return true;
		double tmp;
		if (!cmp_object_as_double(obj, &tmp)) return false;
		(*(float*)value) = tmp;
		return true;
	} else if (type_id == g_StringTypeid) {
		asUINT strsize;
		if (!cmp_object_as_str(obj, &strsize)) return false;
		cmp_buffer* buf = (cmp_buffer*)ctx->buf;
		if (!buf || !buf->data || buf->data->size() - buf->read_cursor < strsize) return false;
		((std::string*)value)->assign((char*)buf->data->data() + buf->read_cursor, strsize);
		buf->read_cursor += strsize;
		return true;
	}
	asITypeInfo* type_info = g_ScriptEngine->GetTypeInfoById(type_id);
	if (!type_info) return false;
	if (strcmp(type_info->GetName(), "dictionary") == 0) {
		asUINT size;
		if (!cmp_object_as_map(obj, &size)) return false;
		for (asUINT i = 0; i < size; i++) {
			std::string key;
			if (!deserialize_value(&key, g_StringTypeid, ctx)) return false;
			cmp_object_t subobj;
			if (!cmp_read_object(ctx, &subobj)) return false;

		}
	}
	return false;
}

std::string serialize(CScriptDictionary& dict) {
	asIScriptContext* ctx = asGetActiveContext();
	asUINT size = dict.GetSize();
	if (size < 1) return "";
	if (!g_StringTypeid)
		g_StringTypeid = g_ScriptEngine->GetStringFactory();
	std::stringstream ss;
	ss.write("\x0e\x16\x07\x14", 4);
	ss.write((char*)&size, 4);
	asUINT keys_written = size;
	for (CScriptDictionary::CIterator it = dict.begin(); it != dict.end(); it++) {
		const std::string& key = it.GetKey();
		unsigned short len = key.size();
		ss.write((char*)&len, 2);
		ss.write(key.c_str(), len);
		int TypeId = it.GetTypeId();
		unsigned char type = 0;
		asINT64 valInt = 0;
		if ((TypeId != asTYPEID_FLOAT && TypeId != asTYPEID_DOUBLE) && it.GetValue(valInt)) {
			type = TypeId == asTYPEID_BOOL ? 1 : 2;
			ss.write((char*)&type, 1);
			ss.write((char*)&valInt, TypeId == asTYPEID_BOOL ? 1 : 8);
			continue;
		}
		double valDouble = 0;
		if (it.GetValue(valDouble)) {
			type = 3;
			ss.write((char*)&type, 1);
			ss.write((char*)&valDouble, 8);
			continue;
		}
		const void* val = it.GetAddressOfValue();
		if (val && TypeId == g_StringTypeid) {
			std::string* valStr = (std::string*)val;
			type = 4;
			ss.write((char*)&type, 1);
			asUINT strsize = valStr->size();
			ss.write((char*)&strsize, 4);
			if (strsize > 0)
				ss.write(valStr->c_str(), strsize);
			continue;
		}
		keys_written -= 1;
	}
	if (keys_written < size) {
		ss.seekp(4, ss.beg);
		ss.write((char*)&keys_written, 4);
	}
	return ss.str();
}

CScriptDictionary* deserialize(const std::string& input) {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	CScriptDictionary* dict = CScriptDictionary::Create(engine);
	if (input == "" || input.size() < 10) return dict;
	std::stringstream ss(input);
	ss.seekp(0, ss.beg);
	char verification[4];
	ss.read(verification, 4);
	if (memcmp(verification, "\x0e\x16\x07\x14", 4) != 0) return dict;
	asUINT size = 0;
	ss.read((char*)&size, 4);
	if (size < 1) return dict;
	if (!g_StringTypeid)
		g_StringTypeid = g_ScriptEngine->GetStringFactory();
	for (int i = 0; i < size; i++) {
		unsigned short keylen = 0;
		ss.read((char*)&keylen, 2);
		if (keylen >= input.size()) return dict;
		std::string key(keylen, '\0');
		ss.read(&key[0], keylen);
		unsigned char type = 0;
		ss.read((char*)&type, 1);
		if (type > 4) return dict;
		if (type == 1) {
			bool val = false;
			ss.read((char*)&val, 1);
			dict->Set(key, &val, asTYPEID_BOOL);
		} else if (type == 2) {
			asINT64 val = 0;
			ss.read((char*)&val, 8);
			dict->Set(key, val);
		} else if (type == 3) {
			double val = 0;
			ss.read((char*)&val, 8);
			dict->Set(key, val);
		} else if (type == 4) {
			int len;
			ss.read((char*)&len, 4);
			std::string val(len, '\0');
			if (len > 0)
				ss.read((char*)&val[0], len);
			dict->Set(key, &val, g_StringTypeid);
		}
	}
	return dict;
}
void packet(asIScriptGeneric* gen) {
	std::string output;
	cmp_buffer buf = {&output, 0};
	cmp_ctx_t ctx = {0, & buf, cmp_read_bytes, cmp_skip_bytes, cmp_write_bytes};
	for (int i = 0; i < gen->GetArgCount(); i++) {
		if (!serialize_value(*(void**)gen->GetAddressOfArg(i), gen->GetArgTypeId(i), &ctx)) break;
	}
	gen->SetReturnObject(&output);
}
#ifdef GetObject // GetObjectW is a function in the win32 API
#undef GetObject
#endif
void unpacket_str(asIScriptGeneric* gen) {
	cmp_buffer buf = {(std::string*)gen->GetObject(), gen->GetArgDWord(0)};
	if (buf.read_cursor < 0 || buf.read_cursor >= buf.data->size()) {
		gen->SetReturnDWord(0);
		return;
	}
	cmp_ctx_t ctx = {0, & buf, cmp_read_bytes, cmp_skip_bytes, cmp_write_bytes};
	unsigned int ret = buf.read_cursor;
	for (int i = 1; i < gen->GetArgCount(); i++) {
		if (deserialize_value(*(void**)gen->GetAddressOfArg(i), gen->GetArgTypeId(i), &ctx)) ret = buf.read_cursor;
		else break;
	}
	gen->SetReturnDWord(ret);
}


void RegisterSerializationFunctions(asIScriptEngine* engine) {
	engine->RegisterObjectMethod("dictionary", "string serialize()", asFUNCTION(serialize), asCALL_CDECL_OBJLAST);
	engine->RegisterGlobalFunction("dictionary@ deserialize(const string& in)", asFUNCTION(deserialize), asCALL_CDECL);
	std::string filler1, filler2;
	for (int i = 0; i < 16; i++) {
		filler1 += "const ?&in";
		filler2 += "const ?&out";
		engine->RegisterGlobalFunction(std::string(std::string("string packet(") + filler1 + ")").c_str(), asFUNCTION(packet), asCALL_GENERIC);
		engine->RegisterObjectMethod("string", std::string(std::string("uint unpacket(uint, ") + filler2 + ")").c_str(), asFUNCTION(unpacket_str), asCALL_GENERIC);
		filler1 += ", ";
		filler2 += ", ";
	}
}
