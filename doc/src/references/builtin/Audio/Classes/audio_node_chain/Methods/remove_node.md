# remove_node
Take a node out of the chain, connecting the nodes on either side of it to each other.

`bool audio_node_chain::remove_node(audio_node@ node);`

`bool audio_node_chain::remove_node(uint index);`

## Arguments:
* audio_node@ node (1): the node to remove.
* uint index (2): the index of the node to remove.

## Returns:
bool: true if the node was removed, false if it isn't in the chain or couldn't be detached.

## Remarks:
The removed node's output is detached, so it no longer sends audio anywhere until it is attached to something else.
