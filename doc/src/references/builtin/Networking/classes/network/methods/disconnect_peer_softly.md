# disconnect_peer_softly
Send a disconnect packet for a peer after sending any remaining packets in the queue and notifying the peer.

`bool network::disconnect_peer_softly(uint peer_id);`

## Arguments:
* uint peer_id: the ID of the peer to disconnect.

## Returns:
bool: true on success, false otherwise.
