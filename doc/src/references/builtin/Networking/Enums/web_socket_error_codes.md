# web_socket_error_codes
The reasons a web socket connection can fail, as reported in the messages of the exceptions thrown.

* WS_ERR_NO_HANDSHAKE: the server didn't respond with a WebSocket handshake.
* WS_ERR_HANDSHAKE_NO_VERSION: the handshake had no WebSocket version.
* WS_ERR_HANDSHAKE_UNSUPPORTED_VERSION: the handshake had an unsupported WebSocket version.
* WS_ERR_HANDSHAKE_NO_KEY: the handshake had no key.
* WS_ERR_HANDSHAKE_ACCEPT: the server's handshake didn't accept the key.
* WS_ERR_UNAUTHORIZED: the server needs authentication.
* WS_ERR_PAYLOAD_TOO_BIG: a frame was larger than max_payload_size.
* WS_ERR_INCOMPLETE_FRAME: a frame was cut short.
