# request
Get the part of the response body that has arrived since it was last read.

`string http::request();`

## Returns:
string: the newly arrived data, which is removed from the http object.

## Remarks:
This is the same as reading response_body.
