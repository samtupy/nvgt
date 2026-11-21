# add_attachment_string
Attach data from a string to the message, as though it were a file.

`bool mail_message::add_attachment_string(const string&in name, const string&in content, const string&in media_type = "application/octet-stream");`

## Arguments:
* const string&in name: the name the attachment is shown with, such as `scores.csv`.
* const string&in content: the data to attach.
* const string&in media_type = "application/octet-stream": the media type of the data, such as `text/csv`.

## Returns:
bool: true if the data was attached, false otherwise, with the reason in last_error.
