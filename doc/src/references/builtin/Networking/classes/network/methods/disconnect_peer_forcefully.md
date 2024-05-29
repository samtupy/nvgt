# disconnect_peer_forcefully
Forcefully disconnect a peer. Unlike `network::disconnect_peer()`, this function doesn't send any sort of notification of the disconnection to the remote peer, instead it closes the connection immediately.

`bool network::disconnect_peer_forcefully(uint peer_id);`

## Arguments:
* uint peer_id: the ID of the peer to disconnect.

## Returns:
bool: true on success, false otherwise.
