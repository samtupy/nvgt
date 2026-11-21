# shutdown
Close the connection in an orderly way by sending a close frame to the other end.

1. `int web_socket::shutdown();`
2. `int web_socket::shutdown(uint16 status_code, const string&in status_message = "");`

## Arguments:
* uint16 status_code (2): the reason for closing, a value of the web_socket_status_codes enum.
* const string&in status_message = "" (2): a short explanation of the reason.

## Returns:
int: the number of bytes sent, or for a non-blocking socket, a negative value if the shutdown must be retried once the socket can be written to.

## Remarks:
Without arguments, the status is WS_NORMAL_CLOSE. The other end answers with a close frame of its own, which receive_frame() returns.
