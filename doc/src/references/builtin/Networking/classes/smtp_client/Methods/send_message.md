# send_message
Send an email.

`bool smtp_client::send_message(mail_message@ message);`

## Arguments:
* mail_message@ message: the message to send, which needs a sender and at least one recipient.

## Returns:
bool: true if the server accepted the message, false otherwise, with the reason in last_error.
