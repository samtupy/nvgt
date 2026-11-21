# peek_response
Receive the response to a request sent with expect_continue, before sending its body.

`bool http_client::peek_response(http_response&inout response);`

## Arguments:
* http_response&inout response: receives the status and headers of the response.

## Returns:
bool: true if the server responded with 100 Continue, in which case the body should be sent and receive_response() called, or false if it sent a final response, which response then holds.
