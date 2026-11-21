# connect_nonblocking
Start connecting to a server without waiting for the connection to be made, making the socket non-blocking.

`void stream_socket::connect_nonblocking(const socket_address&in address);`

## Arguments:
* const socket_address&in address: the address and port to connect to.

## Remarks:
Use poll() with SOCKET_SELECT_WRITE to find out when the connection is made, after which the error property tells whether it succeeded.
