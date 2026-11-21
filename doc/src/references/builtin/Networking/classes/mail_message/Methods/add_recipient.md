# add_recipient
Add a recipient to the message.

1. `void mail_message::add_recipient(const mail_recipient&in recipient);`
2. `void mail_message::add_recipient(const string&in address, mail_recipient_type type = RECIPIENT_TO);`

## Arguments:
* const mail_recipient&in recipient (1): the recipient to add.
* const string&in address (2): the address of the recipient.
* mail_recipient_type type = RECIPIENT_TO (2): whether the recipient is a primary recipient, a carbon copy or a blind carbon copy, a value of the mail_recipient_type enum.
