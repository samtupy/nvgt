# regexp_options
This enum holds various constants that can be passed to the regular expression classes in order to change their behavior.

## Notes:
Portions of this regexp_options documentation were Copied from POCO header files.
* Options marked [ctor] can be passed to the constructor of regexp objects.
* Options marked [match] can be passed to match, extract, split and subst.
* Options marked [subst] can be passed to subst.

See the PCRE documentation for more information.

## Constants:
* RE_CASELESS: case insensitive matching (/i) [ctor]
* RE_MULTILINE: enable multi-line mode; affects ^ and $ (/m) [ctor]
* RE_DOTALL: dot matches all characters, including newline (/s) [ctor]
* RE_EXTENDED: totally ignore whitespace (/x) [ctor]
* RE_ANCHORED: treat pattern as if it starts with a ^ [ctor, match]
* RE_DOLLAR_END_ONLY: dollar matches end-of-string only, not last newline in string [ctor]
* RE_EXTRA: enable optional PCRE functionality [ctor]
* RE_NOT_BOL: circumflex does not match beginning of string [match]
* RE_NOT_EOL: $ does not match end of string [match]
* RE_UNGREEDY: make quantifiers ungreedy [ctor]
* RE_NOT_EMPTY: empty string never matches [match]
* RE_UTF8: assume pattern and subject is UTF-8 encoded [ctor]
* RE_NO_AUTO_CAPTURE: disable numbered capturing parentheses [ctor, match]
* RE_NO_UTF8_CHECK: do not check validity of UTF-8 code sequences [match]
* RE_FIRSTLINE: an unanchored pattern is required to match before or at the first newline in the subject string, though the matched text may continue over the newline [ctor]
* RE_DUPNAMES: names used to identify capturing subpatterns need not be unique [ctor]
* RE_NEWLINE_CR: assume newline is CR ('\r'), the default [ctor]
* RE_NEWLINE_LF: assume newline is LF ('\n') [ctor]
* RE_NEWLINE_CRLF: assume newline is CRLF ("\r\n") [ctor]
* RE_NEWLINE_ANY: assume newline is any valid Unicode newline character [ctor]
* RE_NEWLINE_ANY_CRLF: assume newline is any of CR, LF, CRLF [ctor]
* RE_GLOBAL: replace all occurences (/g) [subst]
* RE_NO_VARS: treat dollar in replacement string as ordinary character [subst]
