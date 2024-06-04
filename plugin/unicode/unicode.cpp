#include "uni_algo/all.h"
#include "../../src/nvgt_plugin.h"
#include "../../src/nvgt.h"
#include <string>
#include <string_view>
#include <cstdint>
#include "scriptarray.h"

std::string lowercase(const std::string& source) {
return una::cases::to_lowercase_utf8(source);
}

std::string uppercase(const std::string& source) {
return una::cases::to_uppercase_utf8(source);
}

std::string casefold(const std::string& source) {
return una::cases::to_casefold_utf8(source);
}

std::string lowercase_with_locale(const std::string& source, const std::string& locale) {
return una::cases::to_lowercase_utf8(source, una::locale(locale));
}

std::string uppercase_with_locale(const std::string& source, const std::string& locale) {
return una::cases::to_uppercase_utf8(source, una::locale(locale));
}

std::string titlecase(const std::string& source) {
return una::cases::to_titlecase_utf8(source);
}

std::string titlecase_with_locale(const std::string& source, const std::string& locale) {
return una::cases::to_titlecase_utf8(source, una::locale(locale));
}

int compare(const std::string& string1, const std::string& string2, const bool case_sensitive) {
if (case_sensitive) {
return una::casesens::compare_utf8(string1, string2);
} else {
return una::caseless::compare_utf8(string1, string2);
}
}

int collate(const std::string& string1, const std::string& string2, const bool case_sensitive) {
if (case_sensitive) {
return una::casesens::collate_utf8(string1, string2);
} else {
return una::caseless::collate_utf8(string1, string2);
}
}

CScriptArray* find(const std::string& string1, const std::string& string2, const bool case_sensitive) {
una::found res;
if (case_sensitive) {
res = una::casesens::find_utf8(string1, string2);
} else {
res = una::caseless::find_utf8(string1, string2);
}
auto start = res.pos();
auto end = res.end_pos();
auto* array = CScriptArray::Create(asGetActiveContext()->GetEngine()->GetTypeInfoByDecl("array<uint64>"));
array->InsertLast(&start);
array->InsertLast(&end);
return array;
}

bool is_valid(const std::string& source) {
return una::is_valid_utf8(source);
}

std::string to_nfc(const std::string& source) {
return una::norm::to_nfc_utf8(source);
}

std::string to_nfd(const std::string& source) {
return una::norm::to_nfd_utf8(source);
}

std::string to_nfkc(const std::string& source) {
return una::norm::to_nfkc_utf8(source);
}

std::string to_nfkd(const std::string& source) {
return una::norm::to_nfkd_utf8(source);
}

std::string to_unaccented(const std::string& source) {
return una::norm::to_unaccent_utf8(source);
}

bool is_nfc(const std::string& source) {
return una::norm::is_nfc_utf8(source);
}

bool is_nfd(const std::string& source) {
return una::norm::is_nfd_utf8(source);
}

bool is_nfkc(const std::string& source) {
return una::norm::is_nfkc_utf8(source);
}

bool is_nfkd(const std::string& source) {
return una::norm::is_nfkd_utf8(source);
}

una::codepoint::general_category get_general_category(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::get_general_category(actual_chars[0]);
}

bool is_alphabetic(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_alphabetic(actual_chars[0]);
}

bool is_numeric(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_numeric(actual_chars[0]);
}

bool is_alphanumeric(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_alphanumeric(actual_chars[0]);
}

bool is_whitespace(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_whitespace(actual_chars[0]);
}

bool is_reserved(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_reserved(actual_chars[0]);
}

bool is_valid_char(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_valid(actual_chars[0]);
}

bool is_valid_scalar(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_valid_scalar(actual_chars[0]);
}

bool is_supplementary(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_supplementary(actual_chars[0]);
}

bool is_noncharacter(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_noncharacter(actual_chars[0]);
}

bool is_surrogate(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_surrogate(actual_chars[0]);
}

bool is_private_use(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_private_use(actual_chars[0]);
}

bool is_control(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::is_control(actual_chars[0]);
}

std::string get_script(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
char32_t script = una::codepoint::get_script(actual_chars[0]);
return una::utf32to8(std::u32string(&script, 1));
}

bool has_script(const std::string& chr, const std::string& script) {
std::u32string actual_chars(chr.begin(), chr.end());
return una::codepoint::has_script(actual_chars[0], una::locale::script(script));
}

plugin_main(nvgt_plugin_shared* shared) {
	prepare_plugin(shared);
shared->script_engine->RegisterEnum("general_category");
shared->script_engine->RegisterEnumValue("general_category", "CN", static_cast<int>(una::codepoint::general_category::Cn));
shared->script_engine->RegisterEnumValue("general_category", "LU", static_cast<int>(una::codepoint::general_category::Lu));
shared->script_engine->RegisterEnumValue("general_category", "LL", static_cast<int>(una::codepoint::general_category::Ll));
shared->script_engine->RegisterEnumValue("general_category", "LT", static_cast<int>(una::codepoint::general_category::Lt));
shared->script_engine->RegisterEnumValue("general_category", "LM", static_cast<int>(una::codepoint::general_category::Lm));
shared->script_engine->RegisterEnumValue("general_category", "LO", static_cast<int>(una::codepoint::general_category::Lo));
shared->script_engine->RegisterEnumValue("general_category", "MN", static_cast<int>(una::codepoint::general_category::Mn));
shared->script_engine->RegisterEnumValue("general_category", "MC", static_cast<int>(una::codepoint::general_category::Mc));
shared->script_engine->RegisterEnumValue("general_category", "ME", static_cast<int>(una::codepoint::general_category::Me));
shared->script_engine->RegisterEnumValue("general_category", "ND", static_cast<int>(una::codepoint::general_category::Nd));
shared->script_engine->RegisterEnumValue("general_category", "NL", static_cast<int>(una::codepoint::general_category::Nl));
shared->script_engine->RegisterEnumValue("general_category", "NO", static_cast<int>(una::codepoint::general_category::No));
shared->script_engine->RegisterEnumValue("general_category", "PC", static_cast<int>(una::codepoint::general_category::Pc));
shared->script_engine->RegisterEnumValue("general_category", "PD", static_cast<int>(una::codepoint::general_category::Pd));
shared->script_engine->RegisterEnumValue("general_category", "PS", static_cast<int>(una::codepoint::general_category::Ps));
shared->script_engine->RegisterEnumValue("general_category", "PE", static_cast<int>(una::codepoint::general_category::Pe));
shared->script_engine->RegisterEnumValue("general_category", "PI", static_cast<int>(una::codepoint::general_category::Pi));
shared->script_engine->RegisterEnumValue("general_category", "PF", static_cast<int>(una::codepoint::general_category::Pf));
shared->script_engine->RegisterEnumValue("general_category", "PO", static_cast<int>(una::codepoint::general_category::Po));
shared->script_engine->RegisterEnumValue("general_category", "SM", static_cast<int>(una::codepoint::general_category::Sm));
shared->script_engine->RegisterEnumValue("general_category", "SC", static_cast<int>(una::codepoint::general_category::Sc));
shared->script_engine->RegisterEnumValue("general_category", "SK", static_cast<int>(una::codepoint::general_category::Sk));
shared->script_engine->RegisterEnumValue("general_category", "SO", static_cast<int>(una::codepoint::general_category::So));
shared->script_engine->RegisterEnumValue("general_category", "ZS", static_cast<int>(una::codepoint::general_category::Zs));
shared->script_engine->RegisterEnumValue("general_category", "ZL", static_cast<int>(una::codepoint::general_category::Zl));
shared->script_engine->RegisterEnumValue("general_category", "ZP", static_cast<int>(una::codepoint::general_category::Zp));
shared->script_engine->RegisterEnumValue("general_category", "CC", static_cast<int>(una::codepoint::general_category::Cc));
shared->script_engine->RegisterEnumValue("general_category", "CF", static_cast<int>(una::codepoint::general_category::Cf));
shared->script_engine->RegisterEnumValue("general_category", "CS", static_cast<int>(una::codepoint::general_category::Cs));
shared->script_engine->RegisterEnumValue("general_category", "CO", static_cast<int>(una::codepoint::general_category::Co));
shared->script_engine->RegisterObjectMethod("string", "string lowercase() const", asFUNCTION(lowercase), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string uppercase() const", asFUNCTION(uppercase), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string casefold() const", asFUNCTION(casefold), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string lowercase(const string&) const", asFUNCTION(lowercase_with_locale), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string uppercase(const string&) const", asFUNCTION(uppercase_with_locale), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string titlecase() const", asFUNCTION(titlecase), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string titlecase(const string&) const", asFUNCTION(titlecase_with_locale), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "int compare(const string&, const bool) const", asFUNCTION(compare), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "int collate(const string&, const bool) const", asFUNCTION(collate), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_valid_unicode() const", asFUNCTION(is_valid), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string to_nfc() const", asFUNCTION(to_nfc), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string to_nfd() const", asFUNCTION(to_nfd), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string to_nfkc() const", asFUNCTION(to_nfkc), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string to_nfkd() const", asFUNCTION(to_nfkd), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string to_unaccented() const", asFUNCTION(to_unaccented), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_nfc() const", asFUNCTION(is_nfc), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_nfd() const", asFUNCTION(is_nfd), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_nfkc() const", asFUNCTION(is_nfkc), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_nfkd() const", asFUNCTION(is_nfkd), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "general_category general_category() const", asFUNCTION(get_general_category), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_alphabetic() const", asFUNCTION(is_alphabetic), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_numeric() const", asFUNCTION(is_numeric), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_alphanumeric() const", asFUNCTION(is_alphanumeric), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_whitespace() const", asFUNCTION(is_whitespace), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_reserved() const", asFUNCTION(is_reserved), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_valid_char() const", asFUNCTION(is_valid_char), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_valid_scalar() const", asFUNCTION(is_valid_scalar), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_supplementary() const", asFUNCTION(is_supplementary), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_noncharacter() const", asFUNCTION(is_noncharacter), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_surrogate() const", asFUNCTION(is_surrogate), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_private_use() const", asFUNCTION(is_private_use), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool is_control() const", asFUNCTION(is_control), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "string get_script() const", asFUNCTION(get_script), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "bool has_script(const string&) const", asFUNCTION(has_script), asCALL_CDECL_OBJFIRST);
shared->script_engine->RegisterObjectMethod("string", "uint64[]@ find(const string&, const bool) const", asFUNCTION(find), asCALL_CDECL_OBJFIRST);
return true;
}
