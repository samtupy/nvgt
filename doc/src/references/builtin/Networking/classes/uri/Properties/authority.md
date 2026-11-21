# authority
The authority of the URI, its user info, host and port, such as `user@nvgt.dev:8080`.

`string uri::authority;`

## Remarks:
When the port is the well known port of the scheme it is left out. Setting the authority parses it and sets user_info, host and port.
