# add_attachment_file
Attach a file to the message.

`bool mail_message::add_attachment_file(const string&in name, const string&in path);`

## Arguments:
* const string&in name: the name the attachment is shown with.
* const string&in path: the path of the file to attach.

## Returns:
bool: true if the file was attached, false if it couldn't be read, with the reason in last_error.
