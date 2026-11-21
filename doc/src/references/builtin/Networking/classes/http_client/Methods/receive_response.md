# receive_response
Receive the response to the request that was sent.

`datastream@ http_client::receive_response(http_response&inout response, const string&in encoding = "", int byteorder = STREAM_BYTE_ORDER_NATIVE);`

## Arguments:
* http_response&inout response: receives the status and headers of the response.
* const string&in encoding = "": the text encoding of the returned stream.
* int byteorder = STREAM_BYTE_ORDER_NATIVE: the byte order of the returned stream.

## Returns:
datastream@: a stream to read the body of the response from.

## Remarks:
The stream belongs to the client and is only valid until the next request. An exception is thrown if receiving fails or times out.
