# send_frame
Send data as a single frame.

`int web_socket::send_frame(const string&in data, int flags = WS_FRAME_TEXT);`

## Arguments:
* const string&in data: the payload of the frame.
* int flags = WS_FRAME_TEXT: the kind of frame to send, usually WS_FRAME_TEXT or WS_FRAME_BINARY. Control frames are sent by combining WS_FRAME_FLAG_FIN with an opcode, such as `WS_FRAME_FLAG_FIN | WS_FRAME_OP_PONG`.

## Returns:
int: the number of bytes sent, or for a non-blocking socket, -1 if the frame couldn't be sent in full, in which case it must be sent again with the same arguments once the socket can be written to.
