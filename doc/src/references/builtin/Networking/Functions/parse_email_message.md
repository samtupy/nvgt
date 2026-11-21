# parse_email_message
Parse an email from its raw text, as stored in a .eml file.

`mail_message@ parse_email_message(const string&in data);`

## Arguments:
* const string&in data: the raw text of the message, its headers followed by its content.

## Returns:
mail_message@: a new mail_message with the sender, recipients, subject, content and threading headers of the email. If the email can't be parsed, the message is empty.

## Remarks:
Only single part messages are fully supported at this time, attachments and alternative content aren't extracted.
