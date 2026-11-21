# set_content
Add text content to the message.

`void mail_message::set_content(const string&in content, const string&in content_type = "text/plain");`

## Arguments:
* const string&in content: the content.
* const string&in content_type = "text/plain": the media type of the content, such as `text/plain` or `text/html`.

## Remarks:
Each call adds another part to the message, so this should usually be called once. For HTML, set_html_content() also includes a plain text version.
