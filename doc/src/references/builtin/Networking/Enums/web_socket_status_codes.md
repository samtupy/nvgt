# web_socket_status_codes
The reasons for closing a web socket connection, passed to web_socket::shutdown().

* WS_NORMAL_CLOSE: 1000, the connection is done with.
* WS_ENDPOINT_GOING_AWAY: 1001, this end is going away, such as a server shutting down.
* WS_PROTOCOL_ERROR: 1002, the other end broke the WebSocket protocol.
* WS_PAYLOAD_NOT_ACCEPTABLE: 1003, a frame held a kind of data that can't be accepted.
* WS_RESERVED: 1004, reserved.
* WS_RESERVED_NO_STATUS_CODE: 1005, reserved to report that no status was given, never sent.
* WS_RESERVED_ABNORMAL_CLOSE: 1006, reserved to report that the connection closed without a close frame, never sent.
* WS_MALFORMED_PAYLOAD: 1007, a frame held data inconsistent with its type, such as invalid UTF-8 in a text frame.
* WS_POLICY_VIOLATION: 1008, a frame broke this end's policy.
* WS_PAYLOAD_TOO_BIG: 1009, a frame was too large to process.
* WS_EXTENSION_REQUIRED: 1010, the server didn't agree to an extension the client needs.
* WS_UNEXPECTED_CONDITION: 1011, the server hit an unexpected problem.
* WS_RESERVED_TLS_FAILURE: 1015, reserved to report a failed TLS handshake, never sent.
