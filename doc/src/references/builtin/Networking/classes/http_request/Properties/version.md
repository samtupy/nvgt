# version
The HTTP version of the message, such as `HTTP/1.1`.

`string http_request::version;`

## Remarks:
The HTTP_1_0 and HTTP_1_1 constants hold the versions. New messages use HTTP/1.0 unless given a version, except that http_request's constructor taking a method defaults to HTTP/1.1.
