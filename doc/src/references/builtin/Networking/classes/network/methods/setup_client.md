# setup_client
Sets up the network object as a client.

`bool network::setup_client(uint8 max_channels, uint16 max_peers);`

## Arguments:
* uint8 max_channels: the maximum number of channels used on the connection (up to 255).
* uint16 max_peers: the maximum number of peers allowed by the connection (maximum is 65535).

## Returns:
bool: true if the client was successfully set up, false otherwise.
