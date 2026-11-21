# expect_continue
Whether the request has an `Expect: 100-continue` header, which asks the server to confirm it will accept the request before its body is sent.

`bool http_request::expect_continue;`

## Remarks:
After sending such a request, use http_client::peek_response() to find out whether to send the body.
