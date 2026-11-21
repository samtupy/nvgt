# set_html_content
Set the content of the message to HTML, with a plain text alternative for mail programs that can't display HTML.

`void mail_message::set_html_content(const string&in html, const string&in plain_alternative = "");`

## Arguments:
* const string&in html: the HTML content.
* const string&in plain_alternative = "": the plain text version. If empty, a note that the message needs HTML support to view is used.

## Remarks:
The parts are added to the message when it is sent.
