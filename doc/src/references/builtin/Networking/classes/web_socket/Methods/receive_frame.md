# receive_frame
Receive a frame.

`string web_socket::receive_frame(int&out flags);`

## Arguments:
* int&out flags: receives the flags and opcode of the frame. `flags & WS_FRAME_OP_BITMASK` is the opcode, one of the web_socket_frame_opcodes values.

## Returns:
string: the payload of the frame. An empty payload with flags of 0 means the other end has closed the connection.

## Remarks:
This blocks until a whole frame has arrived, unless the socket is non-blocking. An exception is thrown if a frame is malformed or larger than max_payload_size, after which the connection must be closed, or if the receive_timeout passes.
