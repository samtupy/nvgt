# font_string_to_tag
Convert a 4 character code, such as an ISO 15924 script code like `Latn` or `Arab`, to the number text_font uses for it.

`uint font_string_to_tag(const string&in str);`

## Arguments:
* const string&in str: the 4 character code.

## Returns:
uint: the code as a number.
