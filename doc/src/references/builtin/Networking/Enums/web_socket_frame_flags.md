# web_socket_frame_flags
Flags of a web socket frame, combined with an opcode in the flags of web_socket::send_frame() and web_socket::receive_frame().

* WS_FRAME_FLAG_FIN: the frame is the final fragment of a message. Frames sent by send_frame() always are.
