# mail_recipient
A recipient of a mail_message, with their address, name and type.

1. `mail_recipient();`
2. `mail_recipient(mail_recipient_type type, const string&in address, const string&in real_name = "");`

## Arguments:
* mail_recipient_type type (2): whether this is a primary recipient, a carbon copy or a blind carbon copy, a value of the mail_recipient_type enum.
* const string&in address (2): the email address of the recipient.
* const string&in real_name = "" (2): the name of the recipient, shown by mail programs alongside the address.

## Remarks:
A recipient created without arguments is a primary recipient with no address.
