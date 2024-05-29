# send_reliable
Attempt to send a packet over the network reliably.

`bool network::send_reliable(uint peer_id, string message, uint8 channel);`

## Arguments:
* uint peer_id: the ID of the peer to send to (specify 1 to send to the server from a client).
* string message: the message to send.
* uint8 channel: the channel to send the message on (see the main networking documentation for more details).

## Returns:
bool: true if the packet was successfully sent, false otherwise.
