# response_headers
The headers of the response, along with its status and reason.

`const http_response@ http::response_headers;`

## Remarks:
This is a copy of the response as it is when read, so it should be read again after the request completes. Before the response arrives, it is empty. A single header can also be read by indexing the http object, such as `h["Content-Type"]`.
