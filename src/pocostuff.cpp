/* pocostuff.cpp - code for wrapping various parts of the Poco c++ libraries
 * Poco is a quite large library with many utilities and modules, this wraps various things from the poco library in cases where we would otherwise be making single c++ files with little wrappers in each.
 * Not everything NVGT uses from poco is wrapped here (for example see threading.cpp), but anything lacking a better place will go here.
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

#include <sstream>
#include <string>
#include <angelscript.h>
#include <obfuscate.h>
#include <scriptarray.h>
// Poco includes:
#include <Poco/Base32Decoder.h>
#include <Poco/Base32Encoder.h>
#include <Poco/Base64Decoder.h>
#include <Poco/Base64Encoder.h>
#include <Poco/Debugger.h>
#include <Poco/Environment.h>
#include <Poco/Format.h>
#include <Poco/Glob.h>
#include <Poco/HexBinaryDecoder.h>
#include <Poco/HexBinaryEncoder.h>
#include <Poco/JSON/Parser.h>
#include <Poco/JSON/Query.h>
#include <Poco/Path.h>
#include <Poco/RegularExpression.h>
#include <Poco/SharedPtr.h>
#include <Poco/String.h>
#include <Poco/TextConverter.h>
#include <Poco/TextEncoding.h>
#include <Poco/TextIterator.h>
#include <Poco/Unicode.h>
#include <Poco/URI.h>
#include <Poco/UTF8Encoding.h>
#include <Poco/UTF8String.h>
#include "datastreams.h"
#include "nvgt.h" // subsystem constants
#include "nvgt_angelscript.h"
#include "pocostuff.h"
using namespace Poco;

// Various string related functions.
std::string string_to_hex(const std::string& str) {
	std::ostringstream ostr;
	HexBinaryEncoder enc(ostr);
	enc.rdbuf()->setLineLength(0);
	enc << str;
	enc.close();
	return ostr.str();
}
std::string hex_to_string(const std::string& str) {
	if (str.size() < 2) return "";
	std::istringstream istr(str);
	istr >> std::noskipws;
	HexBinaryDecoder dec(istr);
	std::string output;
	output.reserve(str.size() / 2);
	char c;
	while (dec.get(c))
		output += c;
	return output;
}
std::string base64_encode(const std::string& str, int options) {
	std::ostringstream ostr;
	Base64Encoder enc(ostr, options);
	enc.rdbuf()->setLineLength(0);
	enc << str;
	enc.close();
	return ostr.str();
}
std::string base64_decode(const std::string& str, int options) {
	if (str.size() < 2) return "";
	std::istringstream istr(str);
	istr >> std::noskipws;
	Poco::Base64Decoder dec(istr, options);
	std::string output;
	output.reserve(str.size() / 3);
	char c;
	while (dec.get(c))
		output += c;
	return output;
}
std::string base32_encode(const std::string& str) {
	std::ostringstream ostr;
	Poco::Base32Encoder enc(ostr);
	enc << str;
	enc.close();
	return ostr.str();
}
std::string base32_decode(const std::string& str) {
	if (str.size() < 2) return "";
	std::istringstream istr(str);
	istr >> std::noskipws;
	Base32Decoder dec(istr);
	std::string output;
	output.reserve(str.size() / 3);
	char c;
	while (dec.get(c))
		output += c;
	return output;
}
std::string string_recode(const std::string& text, const std::string& in_encoding, const std::string& out_encoding, int* errors) {
	try {
		TextConverter tc(TextEncoding::byName(in_encoding), TextEncoding::byName(out_encoding));
		std::string output;
		int ret = tc.convert(text, output);
		if (errors) *errors = ret;
		return output;
	} catch (Poco::Exception) {
		if (errors) *errors = -1;
		return "";
	}
}

// Even more generic string manipulation routines, these used to be in a modified scriptstring_utils addon but now are here because we are taking advantage of Poco's UTF8 support.
static UTF8Encoding g_UTF8;
bool character_is_alphanum(int ch) {
	return Unicode::isAlpha(ch) || Unicode::isDigit(ch);
}
bool string_is(std::string* str, const std::string& encoding, bool(x(int))) {
	if (str->size() < 1) return false;
	TextEncoding& enc = g_UTF8;
	try {
		if (encoding != "") enc = TextEncoding::byName(encoding);
	} catch (...) {
		return false;
	}
	TextIterator it(*str, enc);
	TextIterator end(*str);
	while (it != end) {
		if (!x(*it)) return false;
		++it;
	}
	return true;
}
std::string string_reverse(std::string* str, const std::string& encoding) {
	if (str->size() < 1) return *str;
	TextEncoding& enc = g_UTF8;
	try {
		if (encoding != "") enc = TextEncoding::byName(encoding);
	} catch (...) {
		return *str;
	}
	TextIterator it(*str, enc);
	TextIterator end(*str);
	std::string result(str->size(), '\0'); // Cannot initialize a string to a certain size with uninitialized memory.
	int wpos = str->size();
	unsigned char character[4];
	while (it != end && wpos > 0) {
		int c = enc.convert(*it, character, 4);
		if (!c) {
			character[0] = '?';
			c = 1;
		}
		wpos -= c;
		memcpy(&result[wpos], &character, c); // I don't know if this is the best way, is there an stl function for this?
		++it;
	}
	if (wpos > 0) result.erase(0, wpos);
	return result;
}
bool string_is_lower(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, Unicode::isLower);
}
bool string_is_upper(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, Unicode::isUpper);
}
bool string_is_whitespace(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, Unicode::isSpace);
}
bool string_is_punct(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, Unicode::isPunct);
}
bool string_is_alpha(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, Unicode::isAlpha);
}
bool string_is_digits(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, Unicode::isDigit);
}
bool string_is_alphanum(std::string* str, const std::string& encoding) {
	return string_is(str, encoding, character_is_alphanum);
}
std::string string_upper(std::string* str) {
	return UTF8::toUpper(*str);
}
std::string& string_upper_this(std::string* str) {
	return UTF8::toUpperInPlace(*str);
}
std::string string_lower(std::string* str) {
	return UTF8::toLower(*str);
}
std::string& string_lower_this(std::string* str) {
	return UTF8::toLowerInPlace(*str);
}
void string_remove_BOM(std::string* str) {
	UTF8::removeBOM(*str);
}
std::string string_escape(std::string* str, bool strict_json) {
	return UTF8::escape(*str, strict_json);
}
std::string string_unescape(std::string* str) {
	return UTF8::escape(*str);
}
std::string string_trim_whitespace_left(std::string* str) {
	return trimLeft<std::string>(*str);
}
std::string& string_trim_whitespace_left_this(std::string* str) {
	return trimLeftInPlace<std::string>(*str);
}
std::string string_trim_whitespace_right(std::string* str) {
	return trimRight<std::string>(*str);
}
std::string& string_trim_whitespace_right_this(std::string* str) {
	return trimRightInPlace<std::string>(*str);
}
std::string string_trim_whitespace(std::string* str) {
	return trim<std::string>(*str);
}
std::string& string_trim_whitespace_this(std::string* str) {
	return trimInPlace<std::string>(*str);
}
std::string string_replace_characters(std::string* str, const std::string& from, const std::string& to) {
	return translate<std::string>(*str, from, to);
}
std::string& string_replace_characters_this(std::string* str, const std::string& from, const std::string& to) {
	return translateInPlace<std::string>(*str, from, to);
}
bool string_starts_with(std::string* str, const std::string& value) {
	return startsWith<std::string>(*str, value);
}
bool string_ends_with(std::string* str, const std::string& value) {
	return endsWith<std::string>(*str, value);
}


// Function wrappers for poco var, since we can't register overloaded functions within a class using composition in Angelscript. Sorry, this as well as the below angelscript registration just sucks and I'm not currently clever enough to combine templates and macros to get around all of the horror. Part of me wonders if I should have registered var as a value type or something, but I wish for handles to be supported!
poco_shared<Dynamic::Var>* poco_var_assign_var(poco_shared<Dynamic::Var>* var, const poco_shared<Dynamic::Var>& val) {
	(*var->ptr) = *val.shared;
	return var;
}
template<typename T> poco_shared<Dynamic::Var>* poco_var_assign(poco_shared<Dynamic::Var>* var, const T& val) {
	var->ptr->operator=<T>(val);
	return var;
}
template<typename T> poco_shared<Dynamic::Var>* poco_var_assign_shared(poco_shared<Dynamic::Var>* var, poco_shared<T>* val) {
	var->ptr->operator=(val->shared);
	return var;
}
template<typename T> T poco_var_extract(poco_shared<Dynamic::Var>* var) {
	return var->ptr->convert<T>();
}
template<typename T> poco_shared<T>* poco_var_extract_shared(poco_shared<Dynamic::Var>* var) {
	try {
		return new poco_shared<T>(var->ptr->extract<SharedPtr<T>>());
	} catch (...) {
		return NULL;
	}
}
template<typename T> T poco_var_add_assign(poco_shared<Dynamic::Var>* var, const T& val) {
	var->ptr->operator+=<T>(val);
	return var->ptr->convert<T>();
}
template<typename T> T poco_var_add(poco_shared<Dynamic::Var>* var, const T& val) {
	return var->ptr->template operator+<T>(val).template convert<T>();
}
template<typename T> T poco_var_add_r(poco_shared<Dynamic::Var>* var, const T& val) {
	return val + var->ptr->template convert<T>();
}
poco_shared<Dynamic::Var>* poco_var_inc(poco_shared<Dynamic::Var>* var) {
	var->ptr->operator++();
	return var;
}
poco_shared<Dynamic::Var>* poco_var_dec(poco_shared<Dynamic::Var>* var) {
	var->ptr->operator--();
	return var;
}
int poco_var_cmp(poco_shared<Dynamic::Var>* var, const poco_shared<Dynamic::Var>& other) {
	if ((*var->ptr) < *(other.ptr)) return -1;
	else if ((*var->ptr) > *(other.ptr)) return 1;
	else return 0;
}
template<typename T> T poco_var_sub_assign(poco_shared<Dynamic::Var>* var, const T& val) {
	var->ptr->template operator-=<T>(val);
	return var->ptr->template convert<T>();
}
template<typename T> T poco_var_sub(poco_shared<Dynamic::Var>* var, const T& val) {
	return var->ptr->template operator-<T>(val).template convert<T>();
}
template<typename T> T poco_var_mul_assign(poco_shared<Dynamic::Var>* var, const T& val) {
	var->ptr->template operator*=<T>(val);
	return var->ptr->template convert<T>();
}
template<typename T> T poco_var_mul(poco_shared<Dynamic::Var>* var, const T& val) {
	return var->ptr->template operator*<T>(val).template convert<T>();
}
template<typename T> T poco_var_div_assign(poco_shared<Dynamic::Var>* var, const T& val) {
	var->ptr->template operator/=<T>(val);
	return var->ptr->template convert<T>();
}
template<typename T> T poco_var_div(poco_shared<Dynamic::Var>* var, const T& val) {
	return var->ptr->template operator/<T>(val).template convert<T>();
}
template<typename T> T poco_var_mod_assign(poco_shared<Dynamic::Var>* var, const T& val) {
	T tmp = var->ptr->template convert<T>() % val;
	var->ptr->template operator=<T>(tmp);
	return tmp;
}
template<typename T> T poco_var_mod(poco_shared<Dynamic::Var>* var, const T& val) {
	return var->ptr->template convert<T>() % val;
}
// Special opAssign, opAdd and opAddAssign operator overloads for string, so one can do "str"+var etc.
std::string poco_var_add_string(std::string* var, const poco_shared<Dynamic::Var>& val) {
	return (*var) + val.ptr->convert<std::string>();
}
std::string& poco_var_assign_string(std::string* var, const poco_shared<Dynamic::Var>& val) {
	return (*var) = val.ptr->convert<std::string>();
}
std::string& poco_var_add_assign_string(std::string* var, const poco_shared<Dynamic::Var>& val) {
	return (*var) += val.ptr->convert<std::string>();
}

// Poco encapsolates json parsing in an object. If this turns out to be too slow, use tls/global objects or something.
poco_shared<Dynamic::Var>* json_parse(const std::string& input) {
	JSON::Parser parser;
	return new poco_shared<Dynamic::Var>(new Dynamic::Var(parser.parse(input)));
}
poco_shared<Dynamic::Var>* json_parse_datastream(datastream* input) {
	std::istream* istr = input->get_istr();
	if (!istr) throw InvalidArgumentException("parse_json got a bad datastream");
	JSON::Parser parser;
	return new poco_shared<Dynamic::Var>(new Dynamic::Var(parser.parse(*istr)));
}
// We make a custom json_object class for a couple reasons, mostly so that we can build in poco's json querying as well as other more easily wrapped functions. We'll do very similar for arrays below, I'm not even remotely good enough at this c++ templating thing to avoid this duplicated code and I don't want to meld it all into one class.
poco_json_object::poco_json_object(JSON::Object::Ptr o) : poco_shared<JSON::Object>(std::move(o)) {}
poco_json_object::poco_json_object(poco_json_object* other) : poco_shared<Poco::JSON::Object>(new Poco::JSON::Object(*other->ptr)) {}
poco_json_object& poco_json_object::operator=(poco_json_object* other) {
	(*ptr) = *other->ptr;
	return *this;
}
poco_shared<Dynamic::Var>* poco_json_object::get(const std::string& key, poco_shared<Dynamic::Var>* default_value) const {
	return ptr->has(key)? new poco_shared<Dynamic::Var>(SharedPtr<Dynamic::Var>(new Dynamic::Var(ptr->get(key)))) : default_value; // Oof, more duplication than I like probably?
}
poco_shared<Dynamic::Var>* poco_json_object::get_indexed(const std::string& key) const {
	return new poco_shared<Dynamic::Var>(SharedPtr<Dynamic::Var>(new Dynamic::Var(ptr->get(key)))); // Oof, more duplication than I like probably?
}
poco_shared<Dynamic::Var>* poco_json_object::query(const std::string& path, poco_shared<Dynamic::Var>* default_value) const {
	JSON::Query q(shared); // I tried to cache the query object in the class variable above, and spent an hour or 2 figuring out that this causes a memory access violation in Poco::Dynamic::Var::Var.
	Dynamic::Var result = q.find(path);
	return !result.isEmpty()? new poco_shared<Dynamic::Var>(SharedPtr<Dynamic::Var>(new Dynamic::Var(result))) : default_value;
}
poco_json_array* poco_json_object::get_array(const std::string& key) const {
	JSON::Array::Ptr obj = ptr->getArray(key);
	if (!obj) return nullptr;
	return new poco_json_array(obj);
}
poco_json_object* poco_json_object::get_object(const std::string& key) const {
	JSON::Object::Ptr obj = ptr->getObject(key);
	if (!obj) return nullptr;
	return new poco_json_object(obj);
}
void poco_json_object::set(const std::string& key, poco_shared<Dynamic::Var>* v) {
	ptr->set(key, *v->ptr);
}
bool poco_json_object::is_array(const std::string& key) const {
	return ptr->isArray(key);
}
bool poco_json_object::is_null(const std::string& key) const {
	return ptr->isNull(key);
}
bool poco_json_object::is_object(const std::string& key) const {
	return ptr->isObject(key);
}
std::string poco_json_object::stringify(unsigned int indent, int step) const {
	std::ostringstream ostr;
	ptr->stringify(ostr, indent, step);
	return ostr.str();
}
void poco_json_object::stringify(datastream* ds, unsigned int indent, int step) const {
	if (!ds || !ds->get_ostr()) throw InvalidArgumentException("stream not opened for writing");
	ptr->stringify(*ds->get_ostr(), indent, step);
}
CScriptArray* poco_json_object::get_keys() const {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType, ptr->size());
	int c = 0;
	for (JSON::Object::ConstIterator i = ptr->begin(); i != ptr->end(); i++, c++)((std::string*)(array->At(c)))->assign(i->first);
	return array;
}

poco_json_array::poco_json_array(JSON::Array::Ptr a) : poco_shared<JSON::Array>(std::move(a)) {}
poco_json_array::poco_json_array(poco_json_array* other) : poco_shared<Poco::JSON::Array>(new Poco::JSON::Array(*other->ptr)) {}
poco_json_array& poco_json_array::operator=(poco_json_array* other) {
	(*ptr) = *other->ptr;
	return *this;
}
poco_shared<Dynamic::Var>* poco_json_array::get(unsigned int index) const {
	return new poco_shared<Dynamic::Var>(SharedPtr<Dynamic::Var>(new Dynamic::Var(ptr->get(index))));
}
poco_shared<Dynamic::Var>* poco_json_array::query(const std::string& path) const {
	JSON::Query q(shared);
	return new poco_shared<Dynamic::Var>(SharedPtr<Dynamic::Var>(new Dynamic::Var(q.find(path))));
}
poco_json_array& poco_json_array::extend(poco_json_array* array) {
	if (!array) return *this;
	for (const auto i : *array->ptr) ptr->add(i);
	return *this;
}
poco_json_array* poco_json_array::get_array(unsigned int index) const {
	JSON::Array::Ptr obj = ptr->getArray(index);
	if (!obj) return nullptr;
	return new poco_json_array(obj);
}
poco_json_object* poco_json_array::get_object(unsigned int index) const {
	JSON::Object::Ptr obj = ptr->getObject(index);
	if (!obj) return nullptr;
	return new poco_json_object(obj);
}
void poco_json_array::set(unsigned int index, poco_shared<Dynamic::Var>* v) {
	ptr->set(index, *v->ptr);
}
void poco_json_array::add(poco_shared<Dynamic::Var>* v) {
	ptr->add(*v->ptr);
}
bool poco_json_array::is_array(unsigned int index) const {
	return ptr->isArray(index);
}
bool poco_json_array::is_null(unsigned int index) const {
	return ptr->isNull(index);
}
bool poco_json_array::is_object(unsigned int index) const {
	return ptr->isObject(index);
}
std::string poco_json_array::stringify(unsigned int indent, int step) const {
	std::ostringstream ostr;
	ptr->stringify(ostr, indent, step);
	return ostr.str();
}
void poco_json_array::stringify(datastream* ds, unsigned int indent, int step) const {
	if (!ds || !ds->get_ostr()) throw InvalidArgumentException("stream not opened for writing");
	ptr->stringify(*ds->get_ostr(), indent, step);
}

// Some functions needed to wrap poco regular expression.
static asITypeInfo* StringArrayType = NULL;
std::string poco_regular_expression_extract(RegularExpression* exp, const std::string& subject, std::string::size_type offset, int options) {
	std::string str;
	try {
		if (!exp->extract(subject, offset, str, options)) return "";
	} catch (RegularExpressionException& e) {
		return "";
	}
	return str;
}
std::string poco_regular_expression_extract(RegularExpression* exp, const std::string& subject, std::string::size_type offset) {
	return poco_regular_expression_extract(exp, subject, offset, 0);
}
int poco_regular_expression_subst(RegularExpression* exp, std::string& subject, std::string::size_type offset, const std::string& replacement, int options) {
	try {
		return exp->subst(subject, offset, replacement, options);
	} catch (RegularExpressionException& e) {
		return -1;
	}
}
int poco_regular_expression_subst(RegularExpression* exp, std::string& subject, const std::string& replacement, int options) {
	return poco_regular_expression_subst(exp, subject, 0, replacement, options);
}
CScriptArray* poco_regular_expression_split(RegularExpression* exp, const std::string& subject, std::string::size_type offset, int options) {
	if (!StringArrayType) StringArrayType = g_ScriptEngine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(StringArrayType);
	std::vector<std::string> strings;
	try {
		if (!exp->split(subject, offset, strings, options)) return array;
	} catch (RegularExpressionException& e) {
		return array;
	}
	array->Resize(strings.size());
	for (int i = 0; i < strings.size(); i++)(*(std::string*)array->At(i)) = strings[i];
	return array;
}
CScriptArray* poco_regular_expression_split(RegularExpression* exp, const std::string& subject, std::string::size_type offset) {
	return poco_regular_expression_split(exp, subject, offset, 0);
}
bool poco_regular_expression_match(const std::string& subject, const std::string& pattern, int options) {
	try {
		return RegularExpression::match(subject, pattern, options);
	} catch (RegularExpressionException) {
		return false;
	}
}
bool poco_regular_expression_search(const std::string& subject, const std::string& pattern, int options) {
	try {
		RegularExpression re(pattern, options);
		RegularExpression::Match tmp;
		return re.match(subject, tmp, 0) > 0;
	} catch (RegularExpressionException) {
		return false;
	}
}
std::string poco_regular_expression_replace(const std::string& subject, const std::string& pattern, const std::string& replacement, int options) {
	try {
		std::string ret = subject;
		RegularExpression re(pattern, RegularExpression::RE_UTF8 | options);
		re.subst(ret, replacement, RegularExpression::RE_GLOBAL);
		return ret;
	} catch (RegularExpressionException) {
		return "";
	}
}

// Scriptarray wrappers for URI class.
CScriptArray* uri_get_query_parameters(const URI& u, bool plus_as_space) {
	URI::QueryParameters qp = u.getQueryParameters(plus_as_space);
	CScriptArray* result = CScriptArray::Create(get_array_type("string[][]"), qp.size());
	if (!result || qp.size() < 1) return result;
	for (int i = 0; i < qp.size(); i++) {
		CScriptArray* q = reinterpret_cast<CScriptArray*>(result->At(i));
		q->InsertLast(&qp[i].first);
		q->InsertLast(&qp[i].second);
	}
	return result;
}
CScriptArray* uri_get_path_segments(const URI& u) {
	std::vector<std::string> segments;
	u.getPathSegments(segments);
	return vector_to_scriptarray<std::string>(segments, "string");
}

// ref factories
poco_shared<Dynamic::Var>* poco_var_factory() {
	return new poco_shared<Dynamic::Var>(new Dynamic::Var());
}
template<typename T> poco_shared<Dynamic::Var>* poco_var_factory_value(const T& value) {
	return new poco_shared<Dynamic::Var>(new Dynamic::Var(value));
}
template<typename T> poco_shared<Dynamic::Var>* poco_var_factory_value_shared(poco_shared<T>* value) {
	return new poco_shared<Dynamic::Var>(new Dynamic::Var(value->shared));
}
poco_json_object* poco_json_object_factory() {
	return new poco_json_object(new JSON::Object());
}
poco_json_object* poco_json_object_copy_factory(poco_json_object* other) {
	return new poco_json_object(other);
}
poco_json_object* poco_json_object_list_factory(asBYTE* buffer) {
	poco_json_object* r = new poco_json_object(new JSON::Object());
	asUINT length = *(asUINT*)buffer;
	buffer += 4;
	while (length--) {
		if (asPWORD(buffer) & 0x3)
			buffer += 4 - (asPWORD(buffer) & 0x3);
		std::string name = *(std::string*) buffer;
		buffer += sizeof(std::string);
		poco_shared<Dynamic::Var>* value = *(poco_shared<Dynamic::Var>**) buffer;
		buffer += sizeof(void*);
		r->set(name, value);
	}
	return r;
}
poco_json_array* poco_json_array_factory() {
	return new poco_json_array(new JSON::Array());
}
poco_json_array* poco_json_array_copy_factory(poco_json_array* other) {
	return new poco_json_array(other);
}
poco_json_array* poco_json_array_list_factory(asBYTE* buffer) {
	poco_json_array* r = new poco_json_array(new JSON::Array());
	asUINT length = *(asUINT*)buffer;
	buffer += 4;
	while (length--) {
		if (asPWORD(buffer) & 0x3)
			buffer += 4 - (asPWORD(buffer) & 0x3);
		poco_shared<Dynamic::Var>* value = *(poco_shared<Dynamic::Var>**) buffer;
		buffer += sizeof(void*);
		r->add(value);
	}
	return r;
}
// value constructors and destructors
template <class T, typename... A> void poco_value_construct(T* mem, A... args) { new (mem) T(args...); }
template <class T> void poco_value_copy_construct(T* mem, const T& other) { new (mem) T(other); }
template <class T> void poco_value_destruct(T* mem) { mem->~T(); }

// Template wrapper function to make the registration of types with Dynamic::Var easier.
template<typename T, bool is_string = false> void RegisterPocoVarType(asIScriptEngine* engine, const std::string& type) {
	engine->RegisterObjectBehaviour("var", asBEHAVE_FACTORY, format("var@ v(const %s&in)", type).c_str(), asFUNCTION(poco_var_factory_value<T>), asCALL_CDECL);
	engine->RegisterObjectMethod("var", format("var& opAssign(const %s&in)", type).c_str(), asFUNCTION(poco_var_assign<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", format("%s opAddAssign(const %s&in)", type, type).c_str(), asFUNCTION(poco_var_add_assign<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", format("%s opAdd(const %s&in) const", type, type).c_str(), asFUNCTION(poco_var_add<T>), asCALL_CDECL_OBJFIRST);
	//engine->RegisterObjectMethod("var", format("%s opAddR(const %s&in) const", type, type).c_str(), asFUNCTION(poco_var_add_r<T>), asCALL_CDECL_OBJFIRST);
	if constexpr(!is_string) {
		engine->RegisterObjectMethod("var", format("%s opSubAssign(const %s&in)", type, type).c_str(), asFUNCTION(poco_var_sub_assign<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("var", format("%s opSub(const %s&in) const", type, type).c_str(), asFUNCTION(poco_var_sub<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("var", format("%s opMulAssign(const %s&in)", type, type).c_str(), asFUNCTION(poco_var_mul_assign<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("var", format("%s opMul(const %s&in) const", type, type).c_str(), asFUNCTION(poco_var_mul<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("var", format("%s opDivAssign(const %s&in)", type, type).c_str(), asFUNCTION(poco_var_div_assign<T>), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("var", format("%s opDiv(const %s&in) const", type, type).c_str(), asFUNCTION(poco_var_div<T>), asCALL_CDECL_OBJFIRST);
		if constexpr(std::is_integral<T>::value) {
			engine->RegisterObjectMethod("var", format("%s opModAssign(const %s&in)", type, type).c_str(), asFUNCTION(poco_var_mod_assign<T>), asCALL_CDECL_OBJFIRST);
			engine->RegisterObjectMethod("var", format("%s opMod(const %s&in) const", type, type).c_str(), asFUNCTION(poco_var_mod<T>), asCALL_CDECL_OBJFIRST);
		}
	}
	engine->RegisterObjectMethod("var", format("%s opImplConv() const", type).c_str(), asFUNCTION(poco_var_extract<T>), asCALL_CDECL_OBJFIRST);
}

static std::string g_platform_name, g_platform_display_name, g_platform_version, g_platform_architecture;
void RegisterPocostuff(asIScriptEngine* engine) {
	g_platform_name = Environment::osName();
	g_platform_display_name = Environment::osDisplayName();
	g_platform_version = Environment::osVersion();
	g_platform_architecture = Environment::osArchitecture();
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterObjectBehaviour("var", asBEHAVE_FACTORY, "var @v()", asFUNCTION(poco_var_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("var", asBEHAVE_ADDREF, "void f()", asMETHOD(poco_shared<Dynamic::Var>, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("var", asBEHAVE_RELEASE, "void f()", asMETHOD(poco_shared<Dynamic::Var>, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("var", "var& opAssign(const var&in)", asFUNCTION(poco_var_assign_var), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", "var& opPostInc()", asFUNCTION(poco_var_inc), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", "var& opPostDec()", asFUNCTION(poco_var_dec), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", "int opCmp(const var&in) const", asFUNCTION(poco_var_cmp), asCALL_CDECL_OBJFIRST);
	RegisterPocoVarType<int>(engine, "int");
	RegisterPocoVarType<unsigned int>(engine, "uint");
	RegisterPocoVarType<short>(engine, "int16");
	RegisterPocoVarType<unsigned short>(engine, "uint16");
	RegisterPocoVarType<int64_t>(engine, "int64");
	RegisterPocoVarType<uint64_t>(engine, "uint64");
	RegisterPocoVarType<float>(engine, "float");
	RegisterPocoVarType<double>(engine, "double");
	RegisterPocoVarType<bool, true>(engine, "bool");
	RegisterPocoVarType<std::string, true>(engine, "string");
	engine->RegisterObjectMethod("string", "string opAdd(const var&in) const", asFUNCTION(poco_var_add_string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", "string& opAssign(const var&in)", asFUNCTION(poco_var_assign_string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", "string& opAddAssign(const var&in)", asFUNCTION(poco_var_add_assign_string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", "void clear()", asMETHOD(Dynamic::Var, clear), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectMethod("var", "bool get_empty() const property", asMETHOD(Dynamic::Var, isEmpty), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectMethod("var", "bool get_is_integer() const property", asMETHOD(Dynamic::Var, isInteger), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectMethod("var", "bool get_is_signed() const property", asMETHOD(Dynamic::Var, isSigned), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectMethod("var", "bool get_is_numeric() const property", asMETHOD(Dynamic::Var, isNumeric), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectMethod("var", "bool get_is_boolean() const property", asMETHOD(Dynamic::Var, isBoolean), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectMethod("var", "bool get_is_string() const property", asMETHOD(Dynamic::Var, isString), asCALL_THISCALL, 0, asOFFSET(poco_shared<Dynamic::Var>, ptr), true);
	engine->RegisterObjectBehaviour("var", asBEHAVE_FACTORY, "var @v(json_object@)", asFUNCTION(poco_var_factory_value_shared<JSON::Object>), asCALL_CDECL);
	engine->RegisterObjectMethod("var", "var& opAssign(const json_object&in) const", asFUNCTION(poco_var_assign_shared<JSON::Object>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", "json_object@ opImplCast() const", asFUNCTION(poco_var_extract_shared<JSON::Object>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("var", asBEHAVE_FACTORY, "var @v(json_array@)", asFUNCTION(poco_var_factory_value_shared<JSON::Array>), asCALL_CDECL);
	engine->RegisterObjectMethod("var", "var& opAssign(const json_array&in) const", asFUNCTION(poco_var_assign_shared<JSON::Array>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("var", "json_array@ opImplCast() const", asFUNCTION(poco_var_extract_shared<JSON::Array>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("json_object", asBEHAVE_FACTORY, "json_object @o()", asFUNCTION(poco_json_object_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("json_object", asBEHAVE_FACTORY, "json_object @o(json_object@ other)", asFUNCTION(poco_json_object_copy_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("json_object", asBEHAVE_LIST_FACTORY, "json_object@ f(int&in) {repeat {string, var@}}", asFUNCTION(poco_json_object_list_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("json_object", asBEHAVE_ADDREF, "void f()", asMETHOD(poco_json_object, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("json_object", asBEHAVE_RELEASE, "void f()", asMETHOD(poco_json_object, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "json_object& opAssign(json_object@ other)", asMETHODPR(poco_json_object, operator=, (poco_json_object*), poco_json_object&), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "var@ get_opIndex(const string&in key) const property", asMETHOD(poco_json_object, get_indexed), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "void set_opIndex(const string&in key, const var&in value) property", asMETHOD(poco_json_object, set), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "void set(const string&in key, const var&in value)", asMETHOD(poco_json_object, set), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "var@ get(const string&in key, var@ default_value = null) const", asMETHOD(poco_json_object, get), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "var@ opCall(const string&in path, var@ default_value = null) const", asMETHOD(poco_json_object, query), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "json_array@ get_array(const string&in key) const", asMETHOD(poco_json_object, get_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "json_object@ get_object(const string&in key) const", asMETHOD(poco_json_object, get_object), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "string stringify(uint indent = 0, int step = -1) const", asMETHODPR(poco_json_object, stringify, (unsigned int, int) const, std::string), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "void stringify(datastream@ stream, uint indent = 0, int step = -1) const", asMETHODPR(poco_json_object, stringify, (datastream*, unsigned int, int) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "uint size() const", asMETHOD(JSON::Object, size), asCALL_THISCALL, 0, asOFFSET(poco_json_object, ptr), true);
	engine->RegisterObjectMethod("json_object", "bool get_escape_unicode() const property", asMETHOD(JSON::Object, getEscapeUnicode), asCALL_THISCALL, 0, asOFFSET(poco_json_object, ptr), true);
	engine->RegisterObjectMethod("json_object", "void set_escape_unicode(bool value) property", asMETHOD(JSON::Object, setEscapeUnicode), asCALL_THISCALL, 0, asOFFSET(poco_json_object, ptr), true);
	engine->RegisterObjectMethod("json_object", "void clear()", asMETHOD(JSON::Object, clear), asCALL_THISCALL, 0, asOFFSET(poco_json_object, ptr), true);
	engine->RegisterObjectMethod("json_object", "void remove(const string&in key)", asMETHOD(JSON::Object, remove), asCALL_THISCALL, 0, asOFFSET(poco_json_object, ptr), true);
	engine->RegisterObjectMethod("json_object", "bool exists(const string&in key) const", asMETHOD(JSON::Object, has), asCALL_THISCALL, 0, asOFFSET(poco_json_object, ptr), true);
	engine->RegisterObjectMethod("json_object", "bool is_array(const string&in key) const", asMETHOD(poco_json_object, is_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "bool is_null(const string&in key) const", asMETHOD(poco_json_object, is_null), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "bool is_object(const string&in key) const", asMETHOD(poco_json_object, is_object), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_object", "string[]@ get_keys() const", asMETHOD(poco_json_object, get_keys), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("json_array", asBEHAVE_FACTORY, "json_array @a()", asFUNCTION(poco_json_array_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("json_array", asBEHAVE_FACTORY, "json_array @a(json_array@ other)", asFUNCTION(poco_json_array_copy_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("json_array", asBEHAVE_LIST_FACTORY, "json_array@ f(int&in) {repeat var@}", asFUNCTION(poco_json_array_list_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("json_array", asBEHAVE_ADDREF, "void f()", asMETHOD(poco_json_array, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("json_array", asBEHAVE_RELEASE, "void f()", asMETHOD(poco_json_array, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "json_array& opAssign(json_array@ other)", asMETHODPR(poco_json_array, operator=, (poco_json_array*), poco_json_array&), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "var@ get_opIndex(uint index) property", asMETHOD(poco_json_array, get), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "void set_opIndex(uint index, const var&in value) property", asMETHOD(poco_json_array, set), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "void add(const var&in value)", asMETHOD(poco_json_array, add), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "var@ opCall(const string&in path) const", asMETHOD(poco_json_array, query), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "json_array& extend(const json_array@ array)", asMETHOD(poco_json_array, extend), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "json_array@ get_array(uint index) const", asMETHOD(poco_json_array, get_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "json_object@ get_object(uint index) const", asMETHOD(poco_json_array, get_object), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "string stringify(uint indent = 0, int step = -1)", asMETHODPR(poco_json_array, stringify, (unsigned int, int) const, std::string), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "void stringify(datastream@ stream, uint indent = 0, int step = -1)", asMETHODPR(poco_json_array, stringify, (datastream*, unsigned int, int) const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "uint length()", asMETHOD(JSON::Array, size), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "uint size()", asMETHOD(JSON::Array, size), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "bool get_escape_unicode() property", asMETHOD(JSON::Array, getEscapeUnicode), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "void set_escape_unicode(bool value) property", asMETHOD(JSON::Array, setEscapeUnicode), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "bool get_empty() property", asMETHOD(JSON::Array, empty), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "void clear()", asMETHOD(JSON::Array, clear), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "void remove(uint index)", asMETHOD(JSON::Array, remove), asCALL_THISCALL, 0, asOFFSET(poco_json_array, ptr), true);
	engine->RegisterObjectMethod("json_array", "bool is_array(uint index)", asMETHOD(poco_json_array, is_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "bool is_null(uint index)", asMETHOD(poco_json_array, is_null), asCALL_THISCALL);
	engine->RegisterObjectMethod("json_array", "bool is_object(uint index)", asMETHOD(poco_json_array, is_object), asCALL_THISCALL);
	engine->RegisterGlobalFunction("var@ parse_json(const string&in payload)", asFUNCTION(json_parse), asCALL_CDECL);
	engine->RegisterGlobalFunction("var@ parse_json(datastream@ stream)", asFUNCTION(json_parse_datastream), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_to_hex(const string& in binary)"), asFUNCTION(string_to_hex), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string hex_to_string(const string& in hex)"), asFUNCTION(hex_to_string), asCALL_CDECL);
	engine->RegisterEnum("string_base64_options");
	engine->RegisterEnumValue("string_base64_options", "STRING_BASE64_DEFAULT", 0);
	engine->RegisterEnumValue("string_base64_options", "STRING_BASE64_URL", 1);
	engine->RegisterEnumValue("string_base64_options", "STRING_BASE64_PADLESS", 2);
	engine->RegisterEnumValue("string_base64_options", "STRING_BASE64_URL_PADLESS", 3);
	engine->RegisterGlobalFunction(_O("string string_base64_encode(const string& in binary, string_base64_options options = STRING_BASE64_DEFAULT)"), asFUNCTION(base64_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_base64_decode(const string& in encoded, string_base64_options options = STRING_BASE64_PADLESS)"), asFUNCTION(base64_decode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_base32_encode(const string& in binary)"), asFUNCTION(base32_encode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_base32_decode(const string& in encoded)"), asFUNCTION(base32_decode), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_recode(const string&in text, const string&in in_encoding, const string&in out_encoding, int&out error_count = void)"), asFUNCTION(string_recode), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("void c_debug_message(const string&in message)"), asFUNCTIONPR(Debugger::message, (const std::string&), void), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void c_debug_break()"), asFUNCTIONPR(Debugger::enter, (), void), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void c_debug_break(const string&in message)"), asFUNCTIONPR(Debugger::enter, (const std::string&), void), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_DIRECTORY_HOME() property"), asFUNCTION(Path::home), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_DIRECTORY_COMMON_APPDATA() property"), asFUNCTION(Path::config), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_DIRECTORY_LOCAL_APPDATA() property"), asFUNCTION(Path::dataHome), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool environment_variable_exists(const string&in variable)"), asFUNCTION(Environment::has), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string expand_environment_variables(const string& in text)"), asFUNCTION(Path::expand), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string read_environment_variable(const string&in variable, const string&in default_value = \"\")"), asFUNCTIONPR(Environment::get, (const std::string&, const std::string&), std::string), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void write_environment_variable(const string&in variable, const string&in value)"), asFUNCTION(Environment::set), asCALL_CDECL);
	engine->RegisterGlobalProperty("const string PLATFORM", &g_platform_name);
	engine->RegisterGlobalProperty("const string PLATFORM_DISPLAY_NAME", &g_platform_display_name);
	engine->RegisterGlobalProperty("const string PLATFORM_VERSION", &g_platform_version);
	engine->RegisterGlobalProperty("const string PLATFORM_ARCHITECTURE", &g_platform_architecture);
	engine->RegisterEnum("OPERATING_SYSTEM");
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_FREE_BSD"), POCO_OS_FREE_BSD);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_AIX"), POCO_OS_AIX);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_HPUX"), POCO_OS_HPUX);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_TRU64"), POCO_OS_TRU64);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_LINUX"), POCO_OS_LINUX);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_DARWIN"), POCO_OS_MAC_OS_X);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_NET_BSD"), POCO_OS_NET_BSD);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_OPEN_BSD"), POCO_OS_OPEN_BSD);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_IRIX"), POCO_OS_IRIX);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_SOLARIS"), POCO_OS_SOLARIS);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_QNX"), POCO_OS_QNX);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_VXWORKS"), POCO_OS_VXWORKS);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_CYGWIN"), POCO_OS_CYGWIN);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_NACL"), POCO_OS_NACL);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_ANDROID"), POCO_OS_ANDROID);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_UNKNOWN_UNIX"), POCO_OS_UNKNOWN_UNIX);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_WINDOWS_NT"), POCO_OS_WINDOWS_NT);
	engine->RegisterEnumValue("OPERATING_SYSTEM", _O("OS_VMS"), POCO_OS_VMS);
	engine->RegisterEnum("ARCHITECTURE");
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_ALPHA"), POCO_ARCH_ALPHA);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_IA32"), POCO_ARCH_IA32);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_IA64"), POCO_ARCH_IA64);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_MIPS"), POCO_ARCH_MIPS);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_HPPA"), POCO_ARCH_HPPA);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_PPC"), POCO_ARCH_PPC);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_POWER"), POCO_ARCH_POWER);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_SPARC"), POCO_ARCH_SPARC);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_AMD64"), POCO_ARCH_AMD64);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_ARM"), POCO_ARCH_ARM);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_M68K"), POCO_ARCH_M68K);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_S390"), POCO_ARCH_S390);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_SH"), POCO_ARCH_SH);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_NIOS2"), POCO_ARCH_NIOS2);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_AARCH64"), POCO_ARCH_AARCH64);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_ARM64"), POCO_ARCH_ARM64);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_RISCV64"), POCO_ARCH_RISCV64);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_RISCV32"), POCO_ARCH_RISCV32);
	engine->RegisterEnumValue("ARCHITECTURE", _O("ARCH_LOONGARCH64"), POCO_ARCH_LOONGARCH64);
	engine->RegisterGlobalFunction(_O("OPERATING_SYSTEM get_OS() property"), asFUNCTION(Environment::os), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("ARCHITECTURE get_PROCESSOR_ARCHITECTURE() property"), asFUNCTION(Environment::arch), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint get_PROCESSOR_COUNT() property"), asFUNCTION(Environment::processorCount), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_system_node_name() property"), asFUNCTION(Environment::nodeName), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_system_node_id() property"), asFUNCTIONPR(Environment::nodeId, (), std::string), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_system_is_unix() property"), asFUNCTION(Environment::isUnix), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool get_system_is_windows() property"), asFUNCTION(Environment::isWindows), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string cwdir()"), asFUNCTION(Path::current), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterObjectMethod("string", _O("bool is_upper(const string&in = \"\") const"), asFUNCTION(string_is_upper), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool is_lower(const string&in = \"\") const"), asFUNCTION(string_is_lower), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool is_whitespace(const string&in = \"\") const"), asFUNCTION(string_is_whitespace), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool is_punctuation(const string&in = \"\") const"), asFUNCTION(string_is_punct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool is_alphabetic(const string&in = \"\") const"), asFUNCTION(string_is_alpha), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool is_digits(const string&in = \"\") const"), asFUNCTION(string_is_digits), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool is_alphanumeric(const string&in = \"\") const"), asFUNCTION(string_is_alphanum), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string upper() const"), asFUNCTION(string_upper), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string& upper_this()"), asFUNCTION(string_upper_this), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string lower() const"), asFUNCTION(string_lower), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string& lower_this()"), asFUNCTION(string_lower_this), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string trim_whitespace_left() const"), asFUNCTION(string_trim_whitespace_left), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string& trim_whitespace_left_this()"), asFUNCTION(string_trim_whitespace_left_this), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string trim_whitespace_right() const"), asFUNCTION(string_trim_whitespace_right), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string& trim_whitespace_right_this()"), asFUNCTION(string_trim_whitespace_right_this), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string trim_whitespace() const"), asFUNCTION(string_trim_whitespace), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string& trim_whitespace_this()"), asFUNCTION(string_trim_whitespace_this), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string reverse(const string&in = \"\") const"), asFUNCTION(string_reverse), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string escape(bool = false) const"), asFUNCTION(string_escape), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string unescape() const"), asFUNCTION(string_unescape), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool starts_with(const string&in) const"), asFUNCTION(string_starts_with), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("bool ends_with(const string&in) const"), asFUNCTION(string_ends_with), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string replace_characters(const string&in, const string&in) const"), asFUNCTION(string_replace_characters), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("string& replace_characters_this(const string&in, const string&in)"), asFUNCTION(string_replace_characters_this), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("string", _O("void remove_UTF8_BOM()"), asFUNCTION(string_remove_BOM), asCALL_CDECL_OBJFIRST);
	engine->RegisterEnum("regexp_options");
	engine->RegisterEnumValue("regexp_options", _O("RE_CASELESS"), RegularExpression::RE_CASELESS);
	engine->RegisterEnumValue("regexp_options", _O("RE_MULTILINE"), RegularExpression::RE_MULTILINE);
	engine->RegisterEnumValue("regexp_options", _O("RE_DOTALL"), RegularExpression::RE_DOTALL);
	engine->RegisterEnumValue("regexp_options", _O("RE_EXTENDED"), RegularExpression::RE_EXTENDED);
	engine->RegisterEnumValue("regexp_options", _O("RE_ANCHORED"), RegularExpression::RE_ANCHORED);
	engine->RegisterEnumValue("regexp_options", _O("RE_DOLLAR_END_ONLY"), RegularExpression::RE_DOLLAR_ENDONLY);
	engine->RegisterEnumValue("regexp_options", _O("RE_EXTRA"), RegularExpression::RE_EXTRA);
	engine->RegisterEnumValue("regexp_options", _O("RE_NOT_BOL"), RegularExpression::RE_NOTBOL);
	engine->RegisterEnumValue("regexp_options", _O("RE_NOT_EOL"), RegularExpression::RE_NOTEOL);
	engine->RegisterEnumValue("regexp_options", _O("RE_UNGREEDY"), RegularExpression::RE_UNGREEDY);
	engine->RegisterEnumValue("regexp_options", _O("RE_NOT_EMPTY"), RegularExpression::RE_NOTEMPTY);
	engine->RegisterEnumValue("regexp_options", _O("RE_UTF8"), RegularExpression::RE_UTF8);
	engine->RegisterEnumValue("regexp_options", _O("RE_NO_AUTO_CAPTURE"), RegularExpression::RE_NO_AUTO_CAPTURE);
	engine->RegisterEnumValue("regexp_options", _O("RE_NO_UTF8_CHECK"), RegularExpression::RE_NO_UTF8_CHECK);
	engine->RegisterEnumValue("regexp_options", _O("RE_FIRSTLINE"), RegularExpression::RE_FIRSTLINE);
	engine->RegisterEnumValue("regexp_options", _O("RE_DUPNAMES"), RegularExpression::RE_DUPNAMES);
	engine->RegisterEnumValue("regexp_options", _O("RE_NEWLINE_CR"), RegularExpression::RE_NEWLINE_CR);
	engine->RegisterEnumValue("regexp_options", _O("RE_NEWLINE_LF"), RegularExpression::RE_NEWLINE_LF);
	engine->RegisterEnumValue("regexp_options", _O("RE_NEWLINE_CRLF"), RegularExpression::RE_NEWLINE_CRLF);
	engine->RegisterEnumValue("regexp_options", _O("RE_NEWLINE_ANY"), RegularExpression::RE_NEWLINE_ANY);
	engine->RegisterEnumValue("regexp_options", _O("RE_NEWLINE_ANY_CRLF"), RegularExpression::RE_NEWLINE_ANYCRLF);
	engine->RegisterEnumValue("regexp_options", _O("RE_GLOBAL"), RegularExpression::RE_GLOBAL);
	engine->RegisterEnumValue("regexp_options", _O("RE_NO_VARS"), RegularExpression::RE_NO_VARS);
	engine->RegisterObjectType("regexp", sizeof(RegularExpression), asOBJ_VALUE | asGetTypeTraits<RegularExpression>());
	engine->RegisterObjectBehaviour("regexp", asBEHAVE_CONSTRUCT, _O("void f(const string&in, regexp_options = RE_UTF8)"), asFUNCTION((poco_value_construct<RegularExpression, const std::string&, RegularExpression::Options>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("regexp", asBEHAVE_DESTRUCT, _O("void f()"), asFUNCTION(poco_value_destruct<RegularExpression>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("regexp", _O("bool match(const string&in, uint64 = 0) const"), asMETHODPR(RegularExpression, match, (const std::string&, std::string::size_type) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("regexp", _O("bool match(const string&in, uint64, int) const"), asMETHODPR(RegularExpression, match, (const std::string&, std::string::size_type, int) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("regexp", _O("bool opEquals(const string&in) const"), asMETHOD(RegularExpression, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("regexp", _O("string extract(const string&in, uint64 = 0) const"), asFUNCTIONPR(poco_regular_expression_extract, (RegularExpression*, const std::string&, std::string::size_type), std::string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("regexp", _O("string extract(const string&in, uint64, int) const"), asFUNCTIONPR(poco_regular_expression_extract, (RegularExpression*, const std::string&, std::string::size_type, int), std::string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("regexp", _O("int subst(string&, uint64, const string&in, int = RE_UTF8) const"), asFUNCTIONPR(poco_regular_expression_subst, (RegularExpression*, std::string&, std::string::size_type, const std::string&, int), int), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("regexp", _O("int subst(string&, const string&in, int = RE_UTF8) const"), asFUNCTIONPR(poco_regular_expression_subst, (RegularExpression*, std::string&, const std::string&, int), int), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("regexp", _O("string[]@ split(const string&in, uint64 = 0) const"), asFUNCTIONPR(poco_regular_expression_split, (RegularExpression*, const std::string&, std::string::size_type), CScriptArray*), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("regexp", _O("string[]@ split(const string&in, uint64, int) const"), asFUNCTIONPR(poco_regular_expression_split, (RegularExpression*, const std::string&, std::string::size_type, int), CScriptArray*), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction(_O("bool regexp_match(const string&in, const string&in, int = RE_UTF8)"), asFUNCTION(poco_regular_expression_match), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool regexp_search(const string&in, const string&in, int = RE_UTF8)"), asFUNCTION(poco_regular_expression_search), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string regexp_replace(const string&in, const string&in, const string&in, int = RE_UTF8)"), asFUNCTION(poco_regular_expression_replace), asCALL_CDECL);
	engine->SetDefaultNamespace("spec");
	engine->RegisterEnum("path_style");
	engine->RegisterEnumValue(_O("path_style"), _O("PATH_STYLE_UNIX"), Path::PATH_UNIX);
	engine->RegisterEnumValue(_O("path_style"), _O("PATH_STYLE_URI"), Path::PATH_URI);
	engine->RegisterEnumValue(_O("path_style"), _O("PATH_STYLE_WINDOWS"), Path::PATH_WINDOWS);
	engine->RegisterEnumValue(_O("path_style"), _O("PATH_STYLE_VMS"), Path::PATH_VMS);
	engine->RegisterEnumValue(_O("path_style"), _O("PATH_STYLE_NATIVE"), Path::PATH_NATIVE);
	engine->RegisterEnumValue(_O("path_style"), _O("PATH_STYLE_AUTO"), Path::PATH_GUESS);
	engine->RegisterObjectType("path", sizeof(Path), asOBJ_VALUE | asGetTypeTraits<Path>());
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f()"), asFUNCTION(poco_value_construct<Path>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f(bool)"), asFUNCTION((poco_value_construct<Path, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f(const string&in)"), asFUNCTION((poco_value_construct<Path, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f(const string&in, path_style)"), asFUNCTION((poco_value_construct<Path, const std::string&, Path::Style>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f(const path&in)"), asFUNCTION(poco_value_copy_construct<Path>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f(const path&in, const string&in)"), asFUNCTION((poco_value_construct<Path, const Path&, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_CONSTRUCT, _O("void f(const path&in, const path&in)"), asFUNCTION((poco_value_construct<Path, const Path&, const Path&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("path", asBEHAVE_DESTRUCT, _O("void f()"), asFUNCTION(poco_value_destruct<Path>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("path", _O("path& opAssign(const path&in)"), asMETHODPR(Path, operator=, (const Path&), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& opAssign(const string&in)"), asMETHODPR(Path, operator=, (const std::string&), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& assign(const string&in)"), asMETHODPR(Path, assign, (const std::string&), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& assign(const string&in, path_style)"), asMETHODPR(Path, assign, (const std::string&, Path::Style), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& assign(const path&in)"), asMETHODPR(Path, assign, (const Path&), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& assign_directory(const string&in)"), asMETHODPR(Path, parseDirectory, (const std::string&), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& assign_directory(const string&in, path_style)"), asMETHODPR(Path, parseDirectory, (const std::string&, Path::Style), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("bool parse(const string&in)"), asMETHODPR(Path, tryParse, (const std::string&), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("bool parse(const string&in, path_style)"), asMETHODPR(Path, tryParse, (const std::string&, Path::Style), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("string opImplConv() const"), asMETHODPR(Path, toString, () const, std::string), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("string to_string(path_style = spec::PATH_STYLE_NATIVE) const"), asMETHODPR(Path, toString, (Path::Style) const, std::string), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& make_directory()"), asMETHOD(Path, makeDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& make_file()"), asMETHOD(Path, makeFile), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& make_parent()"), asMETHOD(Path, makeParent), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& make_absolute()"), asMETHODPR(Path, makeAbsolute, (), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& make_absolute(const path&in)"), asMETHODPR(Path, makeAbsolute, (const Path&), Path&), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& append(const path&in)"), asMETHOD(Path, append), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& resolve(const path&in)"), asMETHOD(Path, resolve), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("bool get_is_absolute() const property"), asMETHOD(Path, isAbsolute), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("bool get_is_relative() const property"), asMETHOD(Path, isRelative), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("bool get_is_directory() const property"), asMETHOD(Path, isDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("bool get_is_file() const property"), asMETHOD(Path, isFile), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& set_node(const string&in)"), asMETHOD(Path, setNode), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("const string& get_node() const property"), asMETHOD(Path, getNode), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& set_device(const string&in)"), asMETHOD(Path, setDevice), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("const string& get_device() const property"), asMETHOD(Path, getDevice), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("int get_depth() const property"), asMETHOD(Path, depth), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("const string& get_opIndex(int) const property"), asMETHOD(Path, directory), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& push_directory(const string&in)"), asMETHOD(Path, pushDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& pop_directory()"), asMETHOD(Path, popDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& pop_front_directory()"), asMETHOD(Path, popFrontDirectory), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& set_filename(const string&in)"), asMETHOD(Path, setFileName), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("const string& get_filename() const property"), asMETHOD(Path, getFileName), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& set_basename(const string&in)"), asMETHOD(Path, setBaseName), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("string get_basename() const property"), asMETHOD(Path, getBaseName), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& set_extension(const string&in)"), asMETHOD(Path, setExtension), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("string get_extension() const property"), asMETHOD(Path, getExtension), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("const string& get_vms_version() const property"), asMETHOD(Path, version), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path& clear()"), asMETHOD(Path, clear), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path get_parent() const property"), asMETHOD(Path, parent), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path absolute() const"), asMETHODPR(Path, absolute, () const, Path), asCALL_THISCALL);
	engine->RegisterObjectMethod("path", _O("path absolute(const path&in) const"), asMETHODPR(Path, absolute, (const Path&) const, Path), asCALL_THISCALL);
	engine->RegisterObjectType("uri", sizeof(URI), asOBJ_VALUE | asGetTypeTraits<URI>());
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f()"), asFUNCTION(poco_value_construct<URI>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const string&in uri)"), asFUNCTION((poco_value_construct<URI, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const string&in scheme, const string&in path_etc)"), asFUNCTION((poco_value_construct<URI, const std::string&, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const string&in scheme, const string&in authority, const string&in path_etc)"), asFUNCTION((poco_value_construct<URI, const std::string&, const std::string&, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const string&in scheme, const string&in authority, const string&in path, const string&in query)"), asFUNCTION((poco_value_construct<URI, const std::string&, const std::string&, const std::string&, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const string&in scheme, const string&in authority, const string&in path, const string&in query, const string&in fragment)"), asFUNCTION((poco_value_construct<URI, const std::string&, const std::string&, const std::string&, const std::string&, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const uri&in base_uri, const string&in relative_uri)"), asFUNCTION((poco_value_construct<URI, const URI&, const std::string&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const path&in path)"), asFUNCTION((poco_value_construct<URI, const Path&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_CONSTRUCT, _O("void f(const uri&in)"), asFUNCTION(poco_value_copy_construct<URI>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("uri", asBEHAVE_DESTRUCT, _O("void f()"), asFUNCTION(poco_value_destruct<URI>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uri", _O("uri& opAssign(const uri&in)"), asMETHODPR(URI, operator=, (const URI&), URI&), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("uri& opAssign(const string&in uri)"), asMETHODPR(URI, operator=, (const std::string&), URI&), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("bool opEquals(const uri&in)"), asMETHODPR(URI, operator==, (const URI&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("bool opEquals(const string&in uri)"), asMETHODPR(URI, operator==, (const std::string&) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void clear()"), asMETHOD(URI, clear), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string opImplConv() const"), asMETHOD(URI, toString), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("const string& get_scheme() const property"), asMETHOD(URI, getScheme), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_scheme(const string&in scheme) property"), asMETHOD(URI, setScheme), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("const string& get_user_info() const property"), asMETHOD(URI, getUserInfo), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_user_info(const string&in user_info) property"), asMETHOD(URI, setUserInfo), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("const string& get_host() const property"), asMETHOD(URI, getHost), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_host(const string&in host) property"), asMETHOD(URI, setHost), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("uint16 get_port() const property"), asMETHOD(URI, getPort), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_port(uint16 port) property"), asMETHOD(URI, setPort), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("uint16 get_specified_port() const property"), asMETHOD(URI, getSpecifiedPort), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string get_authority() const property"), asMETHOD(URI, getAuthority), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_authority(const string&in authority) property"), asMETHOD(URI, setAuthority), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("const string& get_path() const property"), asMETHOD(URI, getPath), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_path(const string&in path) property"), asMETHOD(URI, setPath), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string get_query() const property"), asMETHOD(URI, getQuery), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_query(const string&in query) property"), asMETHOD(URI, setQuery), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void add_query_parameter(const string&in param, const string&in value = \"\")"), asMETHOD(URI, addQueryParameter), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("const string& get_raw_query() const property"), asMETHOD(URI, getRawQuery), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_raw_query(const string&in query) property"), asMETHOD(URI, setRawQuery), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string get_fragment() const property"), asMETHOD(URI, getFragment), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_fragment(const string&in fragment) property"), asMETHOD(URI, setFragment), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string get_raw_fragment() const property"), asMETHOD(URI, getRawFragment), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_raw_fragment(const string&in fragment) property"), asMETHOD(URI, setRawFragment), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string get_path_etc() const property"), asMETHOD(URI, getPathEtc), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void set_path_etc(const string&in path_etc) property"), asMETHOD(URI, setPathEtc), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("string get_path_and_query() const property"), asMETHOD(URI, getPathAndQuery), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void resolve(const string&in relative_uri)"), asMETHODPR(URI, resolve, (const std::string&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("void resolve(const uri&in relative_uri)"), asMETHODPR(URI, resolve, (const URI&), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("bool get_is_relative() const property"), asMETHOD(URI, isRelative), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("bool get_is_empty() const property"), asMETHOD(URI, empty), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", _O("bool normalize()"), asMETHOD(URI, normalize), asCALL_THISCALL);
	engine->RegisterObjectMethod("uri", "string[][]@ get_query_parameters(bool plus_as_space = true) const", asFUNCTION(uri_get_query_parameters), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("uri", "string[]@ get_path_segments() const", asFUNCTION(uri_get_path_segments), asCALL_CDECL_OBJFIRST);
	engine->SetDefaultNamespace("");
}
