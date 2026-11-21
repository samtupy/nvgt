# keep_alive
Whether the connection should stay open after the message, from its Connection header.

`bool http_response::keep_alive;`

## Remarks:
Setting this sets the Connection header to Keep-Alive or Close. When the header isn't set, HTTP/1.1 messages keep the connection alive and HTTP/1.0 messages don't.
