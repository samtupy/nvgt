# get_decoded
Get the value of a header, decoding any RFC 2047 encoded words in it, as used by email headers with characters outside ASCII.

`string internet_message_header::get_decoded(const string&in name, const string&in default_value = "");`

## Arguments:
* const string&in name: the name of the header.
* const string&in default_value = "": the value to return if the header isn't there.

## Returns:
string: the decoded value, or default_value.
