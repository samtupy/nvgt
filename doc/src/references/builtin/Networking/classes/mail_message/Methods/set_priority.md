# set_priority
Set the priority of the message, which mail programs may show or sort by.

`void mail_message::set_priority(mail_priority priority);`

## Arguments:
* mail_priority priority: the priority, a value of the mail_priority enum.

## Remarks:
This sets the X-Priority and Importance headers.
