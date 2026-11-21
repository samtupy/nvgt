# set_read_receipt
Ask the recipient's mail program to send a read receipt.

`void mail_message::set_read_receipt(const string&in address);`

## Arguments:
* const string&in address: the address the receipt should be sent to.

## Remarks:
This sets both the Disposition-Notification-To and Return-Receipt-To headers. Many mail programs ask the user first or ignore the request.
