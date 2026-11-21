# content_length
The length of the message's body in bytes, from its Content-Length header.

`int64 http_request::content_length;`

## Remarks:
This is HTTP_UNKNOWN_CONTENT_LENGTH, -1, if the header isn't set, and setting it to that removes the header.
