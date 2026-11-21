# status
The status of the response, a value of the http_status enum, such as HTTP_OK (200) or HTTP_NOT_FOUND (404).

`http_status http_response::status;`

## Remarks:
Calling `set_status(string)` sets the status from a string such as `404`.
