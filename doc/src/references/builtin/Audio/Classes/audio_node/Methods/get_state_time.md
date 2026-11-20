# get_state_time
Get the time at which the node starts or stops.

`uint64 audio_node::get_state_time(audio_node_state state);`

## Arguments:
* audio_node_state state: which transition to get.

## Returns:
uint64: the time on the engine's global clock in PCM frames that was set with `set_state_time()`.
