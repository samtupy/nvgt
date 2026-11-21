# connect
Connect to a server, blocking until the connection is made.

1. `void stream_socket::connect(const socket_address&in address);`
2. `void stream_socket::connect(const socket_address&in address, const timespan&in timeout);`

## Arguments:
* const socket_address&in address: the address and port to connect to.
* const timespan&in timeout (2): the longest time to wait for the connection to be made.

## Remarks:
An exception is thrown if the connection can't be made, such as when nothing is listening at the address or the timeout passes.
