# NVGT Unicode Plugin

This plugin is a unicode library for NVGT. Although NVGT contains functions for encoding/decoding to various encodings, this library provides extensions on the string class specifically designed for unicode and UTF-8 in particular. It is fully compliant with the latest Unicode standard.

## Quick function reference

| function syntax | description |
| ------ | -------- |
| `string lowercase() const`, `string lowercase(const string& locale) const`, `string uppercase() const`, `string uppercase(const string& locale) const`, `string titlecase() const`, `string titlecase(const string& locale) const` | Converts the given string to lowercase, uppercase, or titlecase; if the second overload is called, the given string must be a valid locale string in the form `language`, `language-region`, or `language-region-script`. If specified, the function will attempt to convert the string to the respective case according to both the rules specified in the Unicode standard as well as any locale-specific rules for the given locale, if possible. If the locale is invalid, or if the string is not convertable, the original string is returned. The original string is unmodified and a new string is returned. |
| `string casefold() const` | Performs full case folding and returns the case-folded string. Case folding is a process by which all characters are rendered indistinguishable from the same string had any of it's characters been in another case. For example, titlecase or uppercase letters are mapped to their lowercase equivalents, and sometimes multi-byte sequences are generated to ensure caseless matching. The original string is unmodified and a new string is returned. |
| `int compare(const string& other, const bool case_sensitive) const` | Compares two strings. The source string object is  compared to `other` in lexicagraphical order. If `case_sensitive` is true, then a case-sensitive comparison is performed; otherwise, both strings are case-folded and then compared. The original strings are unmodified. If `other` is lexicagraphically less than `source`, `-1` is returned. If `other` and `source` are lexicagraphically equivalent, `0` is returned. If `other` is lexicalgraphically greater than `source`, `1` is returned. |
| `int collate(const string& other, const bool case_sensitive) const` | Collates two strings. The source string object is collated with `other` according to lexicographical order. If `case_sensitive` is true, a case-sensitive collation is performed; otherwise, both strings are case-folded and then collated. The original strings remain unmodified. If `other` is lexicographically less than `source`, `-1` is returned. If `other` and `source` are lexicographically equivalent, `0` is returned. If `other` is lexicographically greater than `source`, `1` is returned. Collation differs from comparison in that collation takes into account linguistic conventions and complexities beyond simple character code comparisons. It involves normalization and case folding to ensure that strings are ordered in a manner that is culturally and linguistically appropriate. |
| `uint64[2] find(const string& what, const bool case_sensitive) const` | Searches for `what` in the source string. Returns an array of two integers containing the start and end positions of where `what` is found in the source string. |
| `bool is_valid_utf8() const` | Returns true if the source string contains only valid UTF-8. |
| `string to_nfc() const`, `string to_nfd() const`, `string to_nfkc() const`, `string to_nfkd() const` | Normalizes the source string into the respective normalization form (see below) and returns that normalized string. This function should only be called if the source string isn't already normalized, as normalization can be a costly operation. Thus, calling this function in a loop or other iteration-based context is strongly discouraged. |
| `string to_unaccented() const` | Removes accents from the string and returns the newly modified string. Unaccenting occurs by first normalizing the string to normalization form D, removing non-spacing marks, and then normalizing the string to normalization form C. The original string is unmodified. |
| `bool is_nfc() const`, `bool is_nfd() const`, `bool is_nfkc() const`, `bool is_nfkd() const` | Returns true if the source string is in normalization forms C, D, KC or KD. |
| `unicode::general_category get_general_category() const` | Returns the general category of the first character of the source string. No other characters in the string are processed. The general category is used to broadly categorize a character according ot it's characteristics. For a list of categories, see below. |
| `bool is_alphabetic() const`, `bool is_numeric() const`, `bool is_alphanumeric() const`, `bool is_whitespace() const`, `bool is_reserved() const`, `bool is_supplementary() const`, `bool is_noncharacter() const`, `bool is_surrogate() const`, `bool is_private_use() const`, `bool is_control() const` | Returns true if the first character of the string is an alphabetic, numeric, or alphanumeric character; if the first character is a whitespace, reserved, supplementary, surrogate, private use, or control character; or if the first character of the source string is a noncharacter. No other characters of the source string are processed. Supplementary characters are Unicode characters that are encoded outside the Basic Multilingual Plane (BMP), which covers code points from `U+0000` to `U+FFFF`. Reserved characters are code points that have been set aside for potential future use by the Unicode Standard, and do not have assigned characters and are not used for any current character or functionality. Private use characters are code points that are designated for private use and are not assigned specific characters by the Unicode Standard. A noncharacter is a code point that is reserved for internal use and not intented to be used as characters in text. Lastly, surrogate characters are code points in the range `U+D800` to `U+DFFF` that are used in pairs to encode supplementary characters in UTF-16. A high surrogate (`U+D800` to `U+DBFF`) is paired with a low surrogate (`U+DC00` to `U+DFFF`) to represent a single supplementary character. |
| `bool is_valid_char() const` | Returns true if the first character of the source string is a valid character. A valid character is any code point that is not within the surrogate range and not a noncharacter. |
| `bool is_valid_scalar() const` | Returns true if the first character of the source string is a valid scalar character. A scalar character is any Unicode code point that is not a surrogate code point. |
| `string get_script() const` | Returns the script of the first character in the source string. No other characters are processed. |
| `bool has_script(const string& script) const` | Returns true if the source string's first character is of the valid script. No other characters are processed. |

## Normalization forms

Unicode normalization is the process of converting Unicode text into a consistent and unique representation, which is crucial for reliable text processing and comparison. This is particularly important because many Unicode characters can be represented in multiple ways. Unicode defines four main normalization forms, each serving different purposes.

Canonical Decomposition (NFD) decomposes characters into their canonical equivalents. This means breaking down composite characters into their simplest components. For example, the character "é" (U+00E9) is decomposed into "e" (U+0065) and the combining acute accent (U+0301). NFD is useful when you need to perform operations that require character-by-character processing, such as collation (ordering) or text search.

Canonical Decomposition followed by Canonical Composition (NFC) decomposes characters like NFD but then recomposes them into their canonical composed form where possible. The goal is to produce a string that uses the precomposed characters where available. NFC is the most commonly used normalization form. It is ideal for storing and transmitting data because it ensures that text is in a standardized composed form.

Compatibility Decomposition (NFKD) decomposes characters into their compatibility equivalents. This means that it not only breaks down composite characters but also replaces characters with their more basic equivalents if they are considered equivalent in most contexts. For example, the "ﬁ" ligature (U+FB01) is decomposed into "f" (U+0066) and "i" (U+0069). NFKD is used when the exact visual form of the text is not as important as its basic content. It is often used in search engines, text indexing, and other applications where different visual forms should be considered equivalent.

Compatibility Decomposition followed by Canonical Composition (NFKC) decomposes characters like NFKD but then recomposes them into their canonical composed form where possible. It ensures that text is normalized to a consistent form while also simplifying the text to its most basic and compatible components. NFKC is useful for applications where text needs to be normalized for compatibility reasons, but still wants to maintain a composed form where possible. This is often used in data interchange and storage.

### Warning

It is always wise to check to see if a given string is already normalized before normalizing it. Normalization can be expensive, particularly for more complex or longer strings, and if a string is already normalized, normalization is pointless.

## Enumeration reference

### `unicode::general_category`

Contains a list of all general categories. This enumeration is returned by `get_general_category()`.

| Enumerator | Category name | Description |
| --- | --- | --- |
| cn | Unassigned | Code points that are not assigned to any character by the Unicode Standard. These code points are reserved for potential future use. |
| lu | Uppercase letter | Characters classified as uppercase letters. |
| ll | Lowercase letter | Characters classified as lowercase letters. |
| lt | Titlecase letter | Characters designed as title-case letters. |
| lm | Modifier letter | Characters that function as modifiers of other letters, often used in phonetic transcriptions and other linguistic contexts. |
| lo | Other letter | Characters classified as letters that do not fit into the other letter categories, including ideographic characters and letters in scripts that do not have case distinctions. |
| mn | Nonspacing mark | Characters that combine with base characters but do not occupy an additional space. |
| mc | Spacing combining mark | Characters that combine with base characters and occupy an additional space. |
| me | Enclosing mark | Characters that enclose other characters. |
| nd | Decimal number | Characters representing digits in a decimal numeral system. |
| nl | Letter number | Characters that are used as letters but also represent numbers. |
| no | Other number | Characters that denote numbers but are neither decimal digits nor letter numbers, including various numeric symbols and fractions. |
| pc | Connector punctuation | Characters used to connect parts of text. |
| pd | Dash punctuation | Characters that represent dashes. |
| ps | Open punctuation | Characters that are opening brackets or similar symbols. |
| pe | Close punctuation | Characters that are closing brackets or similar symbols. |
| pi | Initial punctuation | Characters that are used at the beginning of quoted text or dialogue. |
| pf | Final punctuation | Characters used at the end of quoted text or dialogue. |
| po | Other punctuation | Characters classified as punctuation that do not fit into the other punctuation categories. |
| sm | Mathematical symbol | Characters used as mathematical symbols. |
| sc | Currency symbol | Characters that denote currency units. |
| sk | Modifier symbol | Characters that modify the meaning or pronunciation of other symbols. |
| so | Other symbol | Characters classified as symbols that do not fit into the other symbol categories. |
| zs | Space separator | Characters that represent spaces. |
| zl | Line separator | Characters that denote line breaks. |
| zp | Paragraph separator | Characters that denote paragraph breaks. |
| cc | Control character | Characters that are control codes. |
| cf | Format character | Characters that provide formatting information without appearing as visible symbols. |
| cs | Surrogate character | Code points reserved for surrogate pairs in UTF-16 encoding. |
| co | Private use | Code points reserved for private use, where their meanings are defined by private agreements and not by the Unicode Standard. |

