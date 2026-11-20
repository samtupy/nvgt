# clear
Remove every node from the chain, connecting its input straight to its endpoint.

`bool audio_node_chain::clear(bool detach_nodes = true);`

## Arguments:
* bool detach_nodes = true: whether to detach the outputs of the removed nodes. Pass false to leave them connected to each other, for example to move a whole set of effects elsewhere.

## Returns:
bool: true if the chain was cleared.
