# opSubAssign
Overloads the -= operator, removing a node from the chain.

`audio_node_chain@ audio_node_chain::opSubAssign(audio_node@ node);`

## Arguments:
* audio_node@ node: the node to remove.

## Returns:
audio_node_chain@: the chain.

## Remarks:
This is the same as `remove_node()`, which can be used instead to find out whether the node was in the chain.
