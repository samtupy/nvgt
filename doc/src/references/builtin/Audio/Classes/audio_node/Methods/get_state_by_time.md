# get_state_by_time
Find out whether the node is started or stopped at a time on the engine's global clock.

`audio_node_state audio_node::get_state_by_time(uint64 global_time);`

## Arguments:
* uint64 global_time: the time in PCM frames.

## Returns:
audio_node_state: AUDIO_NODE_STATE_STARTED if the node is started and within its scheduled start and stop times at that time, otherwise AUDIO_NODE_STATE_STOPPED.
