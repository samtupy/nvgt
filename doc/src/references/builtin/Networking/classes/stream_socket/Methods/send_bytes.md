# send_bytes
Send data through the socket.

`int stream_socket::send_bytes(const string&in data, int flags = 0);`

## Arguments:
* const string&in data: the data to send.
* int flags = 0: flags for the operating system's send function, usually 0.

## Returns:
int: the number of bytes sent, which may be less than the length of the data, in which case the rest should be sent again.

## Remarks:
This blocks until the data can be handed to the operating system, unless the socket is non-blocking. An exception is thrown if sending fails, such as when the connection was lost.
