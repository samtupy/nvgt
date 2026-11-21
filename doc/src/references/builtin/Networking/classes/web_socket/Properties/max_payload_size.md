# max_payload_size
The largest frame payload in bytes that receive_frame() accepts.

`int web_socket::max_payload_size;`

## Remarks:
A larger frame throws an exception. This defaults to the largest value an int can hold, so setting it protects against a server sending enormous frames.
