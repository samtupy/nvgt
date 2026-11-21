# internet_message_header
The headers of an internet message such as an HTTP request or an email, a name_value_collection that can also be read from and written to streams.

1. `internet_message_header();`
2. `internet_message_header(const internet_message_header&in other);`
3. `internet_message_header({{string, string}, ...});`

## Arguments:
* const internet_message_header&in other (2): headers to copy.
* {{string, string}, ...} (3): the names and values of the headers, each pair in its own set of braces.

## Remarks:
This is a name_value_collection with every one of its methods, plus the ones listed here, and is the base of http_request and http_response. It can be created from an initialization list of names and values like a name_value_collection.

An internet_message_header can be cast to an http_request or http_response with cast<http_request@>() if that is what it really is, and converts to a name_value_collection implicitly.
