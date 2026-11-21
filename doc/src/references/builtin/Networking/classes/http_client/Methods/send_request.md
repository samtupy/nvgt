# send_request
Send a request to the server, connecting first if needed.

`datastream@ http_client::send_request(http_request&inout request, const string&in encoding = "", int byteorder = STREAM_BYTE_ORDER_NATIVE);`

## Arguments:
* http_request&inout request: the request to send. Its Host header is set from the client if it has none.
* const string&in encoding = "": the text encoding of the returned stream.
* int byteorder = STREAM_BYTE_ORDER_NATIVE: the byte order of the returned stream.

## Returns:
datastream@: a stream to write the body of the request to, if it has one.

## Remarks:
After writing the body, if any, call receive_response(). An exception is thrown if the connection fails.
