# connect
Attempt to establish a connection with a server, only works when set up as a client.

`uint64 network::connect(string hostname, uint16 port);`

## Arguments:
* string hostname: the hostname/IP address to connect to.
* uint16 port: the port to use.

## Returns:
uint64: the peer ID of the connection, or 0 on error.
