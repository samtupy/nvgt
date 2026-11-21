# shutdown_send
Stop sending on the connection, telling the other end that no more data is coming, while still being able to receive.

`int stream_socket::shutdown_send();`

## Returns:
int: 0, or for a non-blocking TLS connection, a negative value if the shutdown must be retried once the socket can be written to.
