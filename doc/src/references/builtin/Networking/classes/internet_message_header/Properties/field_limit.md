# field_limit
The maximum number of headers read() accepts.

`int internet_message_header::field_limit;`

## Remarks:
This defaults to 100, and protects against a peer sending endless headers. 0 means no limit.
