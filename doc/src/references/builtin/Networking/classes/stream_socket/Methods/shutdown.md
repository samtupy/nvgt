# shutdown
Stop both sending and receiving on the connection, the orderly way of ending it before close().

`int stream_socket::shutdown();`

## Returns:
int: 0, or for a non-blocking TLS connection, a negative value if the shutdown must be retried once the socket can be written to.
