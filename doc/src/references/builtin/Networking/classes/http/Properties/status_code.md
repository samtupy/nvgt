# status_code
The HTTP status code of the response, such as 200 for success or 404 if nothing was found.

`const int http::status_code;`

## Remarks:
This is 0 until the response headers arrive, and stays 0 if the request failed without a response, such as when the host can't be reached. See the http_status enum for the codes, and http_status_reason() to describe one.
