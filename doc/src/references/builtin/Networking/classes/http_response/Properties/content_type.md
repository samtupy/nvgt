# content_type
The media type of the message's body, from its Content-Type header, such as `text/html` or `application/json`.

`string http_response::content_type;`

## Remarks:
This is HTTP_UNKNOWN_CONTENT_TYPE, an empty string, if the header isn't set.
