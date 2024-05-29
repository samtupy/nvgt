# disconnect_peer
Tell a peer to disconnect and completely disregard its message queue. This means that the peer will be told to disconnect without sending any of its queued packets (if any).

`bool network::disconnect_peer(uint peer_id);`

## Arguments:
* uint peer_id: the ID of the peer to disconnect.

## Returns:
bool: true on success, false otherwise.
