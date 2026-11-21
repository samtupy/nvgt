# auto_decode
Whether header values encoded as described by RFC 2047, such as `=?UTF-8?B?...?=`, are decoded automatically as they are read.

`bool internet_message_header::auto_decode;`

## Remarks:
This defaults to false. get_decoded() decodes a single header either way.
