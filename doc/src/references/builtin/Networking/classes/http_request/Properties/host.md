# host
The host the request is for, from its Host header.

`string http_request::host;`

## Remarks:
Calling `set_host(host, port)` sets the host and port together, leaving the port out of the header when it is 80.
