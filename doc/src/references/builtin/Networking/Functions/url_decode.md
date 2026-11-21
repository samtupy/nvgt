# url_decode
Decode a percent encoded string from a URL.

`string url_decode(const string&in url, bool plus_as_space = true);`

## Arguments:
* const string&in url: the string to decode.
* bool plus_as_space = true: whether to decode plus signs as spaces, as web forms encode spaces in queries.

## Returns:
string: the decoded string.
