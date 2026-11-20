# add_node
Insert a node into the chain.

`bool audio_node_chain::add_node(audio_node@ node, audio_node@ after = null, uint input_bus_index = 0);`

`bool audio_node_chain::add_node(audio_node@ node, int after, uint input_bus_index = 0);`

## Arguments:
* audio_node@ node: the node to insert.
* audio_node@ after (1): the node in the chain to insert it after, or null to insert it at the start of the chain.
* int after (2): the index of the node to insert it after, or -1 to insert it at the start.
* uint input_bus_index = 0: the input bus of the node that follows the new one, which the new node's output is attached to.

## Returns:
bool: true if the node was inserted, false if it is null, if `after` is not in the chain or is out of range, or if the connections could not be made.

## Remarks:
Note that calling `add_node(node)` without saying where inserts at the start, so adding several nodes that way puts them in the reverse of the order they were added in. To add nodes one after another, insert each after the `last` node, as in `chain.add_node(node, chain.last)`, or after index `node_count - 1`.

The chain keeps a reference to the node for as long as it is in it.
