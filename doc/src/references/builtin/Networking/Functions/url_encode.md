# url_encode
Percent encode a string so it can be used in a URL, such as in a query parameter.

`string url_encode(const string&in url, const string&in reserved = "");`

## Arguments:
* const string&in url: the string to encode.
* const string&in reserved = "": extra characters to encode, on top of the characters that are never allowed in a URL and those outside of ASCII.

## Returns:
string: the encoded string.

## Remarks:
Characters such as & and = are allowed in URLs, so to encode a value for a query, pass them as reserved, as in `url_encode(value, "&=+#")`. spec::uri::add_query_parameter() does this for you.
