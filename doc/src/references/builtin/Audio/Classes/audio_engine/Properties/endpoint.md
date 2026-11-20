# endpoint
The node at the end of the engine's audio graph, which all audio must be connected to eventually to be heard.

`const audio_node@+ audio_engine::endpoint;`

## Remarks:
Sounds and mixers are connected to it automatically, but it is what you attach the output of a custom node to if you build a graph of your own.
