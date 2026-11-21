# get_header
Get a header of the message.

`string mail_message::get_header(const string&in name) const;`

## Arguments:
* const string&in name: the name of the header.

## Returns:
string: the value of the header, or an empty string if the message doesn't have it.
