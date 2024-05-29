# setup_server
Sets up the network object as a server.

`bool network::setup_server(uint16 bind_port, uint8 max_channels, uint16 max_peers);`

## Arguments:
* uint16 bind_port: the port to bind the server to.
* uint8 max_channels: the maximum number of channels used on the connection (up to 255).
* uint16 max_peers: the maximum number of peers allowed by the connection (maximum is 65535).

## Returns:
bool: true if the server was successfully set up, false otherwise.
