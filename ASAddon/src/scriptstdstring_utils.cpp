// All functions other than string.split and join were written by Sam Tupy for NVGT and fall under that project's zlib license.

#include <assert.h>
#include "scriptstdstring.h"
#include "scriptarray.h"
#include <stdio.h>
#include <string.h>
#include <algorithm>

using namespace std;

BEGIN_AS_NAMESPACE

static asITypeInfo *StringArrayType = NULL;
// This function takes an input string and splits it into parts by looking
// for a specified delimiter. Example:
//
// string str = "A|B||D";
// array<string>@ array = str.split("|");
//
// The resulting array has the following elements:
//
// {"A", "B", "", "D"}
//
// AngelScript signature:
// array<string>@ string::split(const string &in delim, bool full = true) const
static CScriptArray *StringSplit(const string &delim, bool full, const string &str)
{
	// Obtain a pointer to the engine
	asIScriptContext *ctx = asGetActiveContext();
	asIScriptEngine *engine = ctx->GetEngine();

	// TODO: This assumes that CScriptArray was already registered
	if (!StringArrayType)
		StringArrayType = engine->GetTypeInfoByDecl("array<string>");

	// Create the array object
	CScriptArray *array = CScriptArray::Create(StringArrayType);
	if (delim == "")
	{
		array->InsertLast((void*)&str);
		return array;
	}
	asUINT reserved = str.size() * 0.05; // Sam: Not sure how to predict how many elements we should initially reserve as each string could be different. Does it matter?
	array->Reserve(reserved);

	// Find the existence of the delimiter in the input string
	size_t pos = 0, prev = 0;
	asUINT count = 0;
	while((pos = (full? str.find(delim, prev) : str.find_first_of(delim, prev))) != string::npos )
	{
		if (count > reserved)
		{
			reserved *= 8;
			array->Reserve(reserved);
		}
		// Add the part to the array
		array->Resize(array->GetSize()+1);
		((string*)array->At(count))->assign(&str[prev], pos-prev);

		// Find the next part
		count++;
		if (full)
			prev = pos + delim.length();
		else
		{
			prev = pos;
			while (pos + delim.size() - prev > 0 && delim.find_first_of(str.substr(prev, pos+delim.size()-prev))!=string::npos) prev++;
		}
	}

	// Add the remaining part if needed
	if(array->GetSize()<1||str.size()-prev>0)
	{
		array->Resize(array->GetSize()+1);
		((string*)array->At(count))->assign(&str[prev], str.size()-prev);
	}
	array->Resize(array->GetSize());

	return array;
}

static void StringSplit_Generic(asIScriptGeneric *gen)
{
	// Get the arguments
	string *str   = (string*)gen->GetObject();
	string *delim = *(string**)gen->GetAddressOfArg(0);
	bool full = gen->GetArgByte(1);

	// Return the array by handle
	*(CScriptArray**)gen->GetAddressOfReturnLocation() = StringSplit(*delim, full, *str);
}



// This function takes as input an array of string handles as well as a
// delimiter and concatenates the array elements into one delimited string.
// Example:
//
// array<string> array = {"A", "B", "", "D"};
// string str = join(array, "|");
//
// The resulting string is:
//
// "A|B||D"
//
// AngelScript signature:
// string join(const array<string> &in array, const string &in delim)
static string StringJoin(const CScriptArray &array, const string &delim)
{
	// Create the new string
	string str = "";
	if( array.GetSize() )
	{
		int n;
		for( n = 0; n < (int)array.GetSize() - 1; n++ )
		{
			str += *(string*)array.At(n);
			str += delim;
		}

		// Add the last part
		str += *(string*)array.At(n);
	}

	return str;
}

static void StringJoin_Generic(asIScriptGeneric *gen)
{
	// Get the arguments
	CScriptArray  *array = *(CScriptArray**)gen->GetAddressOfArg(0);
	string *delim = *(string**)gen->GetAddressOfArg(1);

	// Return the string
	new(gen->GetAddressOfReturnLocation()) string(StringJoin(*array, *delim));
}
// As an alternativve to string::substr, this function returns a substring of the input string by emulating Python's string slicing, or at least a convenient subset of it.
// The only slight oddity is that since angelscript doesn't support blank arguments in cases such as str[5:] or str[:-4], we use the number 0 to indicate such slices.
// "hello".slice(0, 2) returns "he"
// "hello".slice(0, 0) returns "hello" because in angelscript we cannot emulate "hello"[0:]
// "hello".slice(-3, 0) returns "llo" because in angelscript we cannot emulate "hello"[-3:]
//
// AngelScript signature:
// string string::slice(int start = 0, int end = 0) const
static string StringSlice(int start, int end, const string &str)
{
	asUINT size = str.size();
	if( start < 0 )
		start = size + start;
	if( end <= 0 )
		end = size - end;
	if( end >= size )
		end = size;
	int count = end - start;
	if( start < 0 || count <= 0 || start >= size)
return "";
	return str.substr(start, count);
}

// This function replaces a range of bytes(start, count) with a string of text.
//
// AngelScript signature:
// string string::replaceRange(uint start, int count, string& replace) const
static string StringReplaceRange(asUINT start, int count, const string& replace, const string &str)
{
	if( start >= str.size() || count < 1 )
		return str;
	// Recreate the string so that the original stays in tact.
	string ret(&str[0], start);
	ret+=replace;
	ret.append(str, start+count, str.size()-(start+count));
	return ret;
}

// This function replaces a given substring of text with another.
// Set replaceAll to false to only replace the first occurrence of the text.
//
// AngelScript signature:
// string string::replace(string& search, string& replace) const
static string StringReplace(const string& search, const string& replace, bool replaceAll, asUINT offset, const string &str)
{
	if( search == "" || str == "")
		return str;
	string ret=str;
	int replacementCount = 0;
	size_t pos = ret.find(search, offset);
	while ((pos = ret.find(search, pos)) != string::npos)
	{
		ret.replace(pos, search.length(), replace);
		pos += replace.length();
		replacementCount += 1;
		if( replacementCount > 0 && !replaceAll )
			break;
	}
	return ret;
}
// Like above, but does so in place.
static string& StringReplaceThis(const string& search, const string& replace, bool replaceAll, asUINT offset, string &str)
{
	if( search == "" || str == "")
		return str;
	int replacementCount = 0;
	size_t pos = str.find(search, offset);
	while ((pos = str.find(search, pos)) != string::npos)
	{
		str.replace(pos, search.length(), replace);
		pos += replace.length();
		replacementCount += 1;
		if( replacementCount > 0 && !replaceAll )
			break;
	}
	return str;
}

static void StringSlice_Generic(asIScriptGeneric *gen)
{
	// Get the arguments
	string *str   = (string*)gen->GetObject();
	int  start = *(int*)gen->GetAddressOfArg(0);
	int     end = *(int*)gen->GetAddressOfArg(1);

	// Return the substring
	new(gen->GetAddressOfReturnLocation()) string(StringSlice(start, end, *str));
}

static void StringReplaceRange_Generic(asIScriptGeneric * gen)
{
	asUINT start = gen->GetArgDWord(1);
	int count = gen->GetArgDWord(2);
	string *replace = reinterpret_cast<string*>(gen->GetArgAddress(3));
	string *self = reinterpret_cast<string *>(gen->GetObject());
	*reinterpret_cast<string *>(gen->GetAddressOfReturnLocation()) = StringReplaceRange(start, count, *replace, *self);
}

static void StringReplace_Generic(asIScriptGeneric * gen)
{
	string *search = reinterpret_cast<string*>(gen->GetArgAddress(1));
	string *replace = reinterpret_cast<string*>(gen->GetArgAddress(2));
	bool replaceAll = gen->GetArgByte(3);
	asUINT offset=gen->GetArgDWord(4);
	string *self = reinterpret_cast<string *>(gen->GetObject());
	*reinterpret_cast<string *>(gen->GetAddressOfReturnLocation()) = StringReplace(*search, *replace, replaceAll, offset, *self);
}



// Returns a reversed version of the given string.
//
// AngelScript signature:
// string string::reverse() const
static string StringReverse(const string &str)
{
string ret(&str[0], str.size());
std::reverse(ret.begin(), ret.end());
return ret;
}
// Returns a lower case version of the given string.
//
// AngelScript signature:
// string string::lower() const
static string StringLower(const string &str)
{
	string ret;
	ret.reserve(str.size());
	for(int i = 0; i < str.size(); i++)
		ret+=tolower(str[i]);
	return ret;
}

// Returns an upper case version of the given string.
//
// AngelScript signature:
// string string::lower() const
static string StringUpper(const string &str)
{
	string ret;
	ret.reserve(str.size());
	for(int i = 0; i < str.size(); i++)
		ret+=toupper(str[i]);
	return ret;
}

// Returns true if this string is lowercase.
//
// AngelScript signature:
// bool string::isLower() const
static bool StringIsLower(const string &str)
{
for(int i=0; i<str.size(); i++)
{
if(!islower(str[i])) return false;
}
return true;
}

// Returns true if this string is uppercase.
//
// AngelScript signature:
// bool string::isUpper() const
static bool StringIsUpper(const string &str)
{
for(int i=0; i<str.size(); i++)
{
if(!isupper(str[i])) return false;
}
return true;
}

// Returns true if this string is punctuation.
//
// AngelScript signature:
// bool string::isPunct() const
static bool StringIsPunct(const string &str)
{
for(int i=0; i<str.size(); i++)
{
if(!ispunct(str[i])) return false;
}
return true;
}

// Returns true if this string is digits.
//
// AngelScript signature:
// bool string::isDigit() const
static bool StringIsDigit(const string &str)
{
if(str.size()<1) return false;
for(int i=0; i<str.size(); i++)
{
if(!isdigit(str[i])) return false;
}
return true;
}

// Returns true if this string is alphabetic.
//
// AngelScript signature:
// bool string::isAlpha() const
static bool StringIsAlpha(const string &str)
{
for(int i=0; i<str.size(); i++)
{
if(!isalpha(str[i])) return false;
}
return true;
}

// Returns true if this string is alphabetic or numeric.
//
// AngelScript signature:
// bool string::isAlphanum() const
static bool StringIsAlphanum(const string &str)
{
for(int i=0; i<str.size(); i++)
{
if(!isalpha(str[i])&&!isdigit(str[i])) return false;
}
return true;
}

static string string_multiply(const string& str, asUINT multiplier)
{
	if (multiplier == 0) return "";
	else if (multiplier == 1) return str;
	string result = str;
	result.reserve(str.size() * multiplier);
	for (asUINT i = 0; i < multiplier -1; i++) result += str;
	return result;
}
static string& string_multiply_assign(string& str, asUINT multiplier)
{
	if (multiplier == 0)
	{
		str = "";
		str.shrink_to_fit();
		return str;
	}
	else if (multiplier == 1) return str;
	str.reserve(str.size() * multiplier);
	string tmp = str;
	for (asUINT i = 0; i < multiplier -1; i++) str += tmp;
	return str;
}
static asQWORD string_count(string& str, const string& search, asQWORD start) {
	if (str.empty() || search.empty()) return 0;
	asUINT c = 0;
	while (true) {
		size_t pos = str.find(search, start);
		if (pos == std::string::npos) break;
		start = pos + 1;
		c++;
	}
	return c;
}

// This is where the utility functions are registered.
// The string type must have been registered first.
void RegisterStdStringUtils(asIScriptEngine *engine)
{
	int r;

	if( strstr(asGetLibraryOptions(), "AS_MAX_PORTABILITY") )
	{
		r = engine->RegisterObjectMethod("string", "array<string>@ split(const string &in, bool = true) const", asFUNCTION(StringSplit_Generic), asCALL_GENERIC); assert(r >= 0);
		r = engine->RegisterGlobalFunction("string join(const array<string> &in, const string &in)", asFUNCTION(StringJoin_Generic), asCALL_GENERIC); assert(r >= 0);
	r = engine->RegisterObjectMethod("string", "string slice(int start = 0, int end = 0) const", asFUNCTION(StringSlice_Generic), asCALL_GENERIC); assert(r >= 0);
		r = engine->RegisterObjectMethod("string", "string replace_range(uint start, int count, const string& in) const", asFUNCTION(StringReplaceRange_Generic), asCALL_GENERIC); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string replace(const string& in, const string& in, bool = true, uint = 0) const", asFUNCTION(StringReplace_Generic), asCALL_GENERIC); assert( r >= 0 );
	}
	else
	{
		r = engine->RegisterObjectMethod("string", "array<string>@ split(const string &in, bool = true) const", asFUNCTION(StringSplit), asCALL_CDECL_OBJLAST); assert(r >= 0);
		r = engine->RegisterGlobalFunction("string join(const array<string> &in, const string &in)", asFUNCTION(StringJoin), asCALL_CDECL); assert(r >= 0);
		r = engine->RegisterObjectMethod("string", "string slice(int start = 0, int end = 0) const", asFUNCTION(StringSlice), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string replace_range(uint start, int count, const string& in) const", asFUNCTION(StringReplaceRange), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string replace(const string& in, const string& in, bool = true, uint = 0) const", asFUNCTION(StringReplace), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string& replace_this(const string& in, const string& in, bool = true, uint = 0) const", asFUNCTION(StringReplaceThis), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string reverse_bytes() const", asFUNCTION(StringReverse), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string opMul(uint) const", asFUNCTION(string_multiply), asCALL_CDECL_OBJFIRST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "string& opMulAssign(uint)", asFUNCTION(string_multiply_assign), asCALL_CDECL_OBJFIRST); assert( r >= 0 );
		r = engine->RegisterObjectMethod("string", "uint64 count(const string&in search, uint64 start = 0) const", asFUNCTION(string_count), asCALL_CDECL_OBJFIRST); assert( r >= 0 );
		// r = engine->RegisterObjectMethod("string", "string lower() const", asFUNCTION(StringLower), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		// r = engine->RegisterObjectMethod("string", "string upper() const", asFUNCTION(StringUpper), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		// r = engine->RegisterObjectMethod("string", "bool is_lower() const", asFUNCTION(StringIsLower), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		//r = engine->RegisterObjectMethod("string", "bool is_upper() const", asFUNCTION(StringIsUpper), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		//r = engine->RegisterObjectMethod("string", "bool is_punctuation() const", asFUNCTION(StringIsPunct), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		//r = engine->RegisterObjectMethod("string", "bool is_alphabetic() const", asFUNCTION(StringIsAlpha), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		//r = engine->RegisterObjectMethod("string", "bool is_digits() const", asFUNCTION(StringIsDigit), asCALL_CDECL_OBJLAST); assert( r >= 0 );
		//r = engine->RegisterObjectMethod("string", "bool is_alphanumeric() const", asFUNCTION(StringIsAlphanum), asCALL_CDECL_OBJLAST); assert( r >= 0 );
	}
}

END_AS_NAMESPACE
