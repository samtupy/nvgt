# flush_request
Make sure everything written to the request's stream has been sent to the server.

`void http_client::flush_request();`

## Remarks:
receive_response() does this itself.
