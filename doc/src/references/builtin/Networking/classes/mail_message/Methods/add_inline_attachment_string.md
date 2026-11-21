# add_inline_attachment_string
Attach data from a string to the message so it can be shown within its HTML content.

`string mail_message::add_inline_attachment_string(const string&in content, const string&in media_type, const string&in content_id);`

## Arguments:
* const string&in content: the data to attach.
* const string&in media_type: the media type of the data, such as `image/png`.
* const string&in content_id: the content ID to give the attachment. If empty, `inline@nvgt.mail` is used, so give each attachment a unique ID.

## Returns:
string: the content ID, or an empty string if the data couldn't be attached, with the reason in last_error.
