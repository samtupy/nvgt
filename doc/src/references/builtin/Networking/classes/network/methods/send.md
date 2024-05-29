# send
Attempt to send a packet over the network.

`bool network::send(uint peer_id, string message, uint8 channel, bool reliable = true);`

## Arguments:
* uint peer_id: the ID of the peer to send to (specify 1 to send to the server from a client).
* string message: the message to send.
* uint8 channel: the channel to send the message on (see the main networking documentation for more details).
* bool reliable = true: whether or not the packet should be sent reliably or not (see the main networking documentation for more details).

## Returns:
bool: true if the packet was successfully sent, false otherwise.
