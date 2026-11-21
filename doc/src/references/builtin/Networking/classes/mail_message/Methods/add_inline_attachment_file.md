# add_inline_attachment_file
Attach a file to the message so it can be shown within its HTML content, such as an image.

`string mail_message::add_inline_attachment_file(const string&in path, const string&in content_id = "");`

## Arguments:
* const string&in path: the path of the file to attach.
* const string&in content_id = "": the content ID to give the attachment. If empty, the filename followed by `@nvgt.mail` is used.

## Returns:
string: the content ID, which the HTML refers to as `cid:` followed by the ID, or an empty string if the file couldn't be attached, with the reason in last_error.
