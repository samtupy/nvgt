# send_messages
Send several emails over the same connection.

`bool smtp_client::send_messages(array<mail_message@>@ messages);`

## Arguments:
* array<mail_message@>@ messages: the messages to send.

## Returns:
bool: true if the server accepted every message, false if one failed, with the reason in last_error. The messages before it were sent, and the ones after it weren't.
