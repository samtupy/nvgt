# internal_node_chain
The chain of nodes that the mixer's audio passes through on its way to its output, holding its effects chain and its spatializer.

`const audio_node_chain@ mixer::internal_node_chain;`

## Remarks:
This is for advanced uses that need to insert a node somewhere other than in the `effects_chain`, such as after the spatializer. Removing the nodes the mixer put there itself will break its effects or positioning.
