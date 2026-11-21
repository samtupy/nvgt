# bind
Bind the socket to a local address and port, before connecting from it.

`bool stream_socket::bind(const socket_address&in address, bool reuse_address = false, bool IPv6_only = false);`

## Arguments:
* const socket_address&in address: the local address and port to bind to.
* bool reuse_address = false: whether to allow binding to an address still in use by a recently closed connection.
* bool IPv6_only = false: for an IPv6 address, whether to refuse IPv4 connections mapped to IPv6.

## Returns:
bool: true once the socket is bound. An exception is thrown if it can't be.
