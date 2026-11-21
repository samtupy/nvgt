# web_socket_frame_opcodes
The kinds of web socket frames, found in the flags returned by web_socket::receive_frame() with `flags & WS_FRAME_OP_BITMASK`.

* WS_FRAME_OP_CONT: a continuation of a fragmented message.
* WS_FRAME_OP_TEXT: a text frame, holding UTF-8 text.
* WS_FRAME_OP_BINARY: a binary frame.
* WS_FRAME_OP_CLOSE: a close frame, after which the connection ends.
* WS_FRAME_OP_PING: a ping, which should be answered with a pong holding the same data.
* WS_FRAME_OP_PONG: a pong, the answer to a ping.
* WS_FRAME_OP_BITMASK: the bits of the flags holding the opcode.
* WS_FRAME_OP_SETRAW: send the flags as given, for advanced uses such as fragmenting messages.
