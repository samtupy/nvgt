# opAddAssign
Overloads the += operator, adding a node, or a list of nodes in order, to the end of the chain.

1. `audio_node_chain@ audio_node_chain::opAddAssign(audio_node@ node);`
2. `audio_node_chain@ audio_node_chain::opAddAssign(const audio_node@[]@ nodes);`

## Arguments:
* audio_node@ node (1): the node to add.
* const audio_node@[]@ nodes (2): the nodes to add, which can be an initializer list.

## Returns:
audio_node_chain@: the chain.

## Remarks:
This lets effects be added in one line, as in `sound.effects_chain += {audio_high_pass_filter(500, 2), audio_low_pass_filter(3000, 2)};`. Use `add_node()` or `add_nodes()` instead to find out whether the nodes could be added.
