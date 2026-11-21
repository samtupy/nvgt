# chunked_transfer_encoding
Whether the message's body is sent with chunked transfer encoding.

`bool http_response::chunked_transfer_encoding;`

## Remarks:
Setting this to true sets the Transfer-Encoding header to chunked, which also removes any Content-Length header.
