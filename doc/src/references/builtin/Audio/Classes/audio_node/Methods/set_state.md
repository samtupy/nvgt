# set_state
Start or stop the node.

`bool audio_node::set_state(audio_node_state state);`

## Arguments:
* audio_node_state state: the new state.

## Returns:
bool: true if the state was set.

## Remarks:
A stopped node produces silence, and anything that depends on it for input goes quiet. Sounds and other nodes that play things should normally be controlled with their own methods such as `play()` and `stop()`, which do this for you.
