#include "uni_algo/all.h"
#include "../../src/nvgt_plugin.h"
#include <string>
#include <string_view>
#include <tuple>
#include <cstdint>

std::string lowercase(const std::string& source) {
return una::cases::to_lowercase_utf8(source);
}

std::string uppercase(const std::string& source) {
return una::cases::to_uppercase_utf8(source);
}

std::string casefold(const std::string& source) {
return una::cases::to_casefold_utf8(source);
}

std::string lowercase(const std::string& source, const std::string& locale) {
return una::cases::to_lowercase_utf8(source, una::locale(locale));
}

std::string uppercase(const std::string& source, const std::string& locale) {
return una::cases::to_uppercase_utf8(source, una::locale(locale));
}

std::string titlecase(const std::string& source) {
return una::cases::to_titlecase_utf8(source);
}

std::string titlecase(const std::string& source, const std::string& locale) {
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

// To do: figure out how to encode this into angelscript, as tuples are not currently available
std::tuple<std::size_t, std::size_t> find(const std::string& string1, const std::string& string2, const bool case_sensitive) {
una::found res;
if (case_sensitive) {
res = una::casesens::find_utf8(string1, string2);
} else {
res = una::caseless::find_utf8(string1, string2);
}
return {res.pos(), res.end_pos()};
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

std::uint8_t get_general_category(const std::string& chr) {
std::u32string actual_chars(chr.begin(), chr.end());
return static_cast<std::uint8_t>(una::codepoint::get_general_category(actual_chars[0]));
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

bool is_valid(const std::string& chr) {
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
return una::utf32to8(script);
}

bool has_script(const std::string& chr, const std::string& scr) {
std::u32string actual_chars(chr.begin(), chr.end());
std::u32string script(scr.begin(), scr.end());
return una::codepoint::has_script(actual_chars[0], una::locale::script(script[0]));
}

