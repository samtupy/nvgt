# get_state_by_time_range
Find out whether the node is started at any point within a range of the engine's global clock.

`audio_node_state audio_node::get_state_by_time_range(uint64 global_time_begin, uint64 global_time_end);`

## Arguments:
* uint64 global_time_begin: the start of the range in PCM frames.
* uint64 global_time_end: the end of the range in PCM frames.

## Returns:
audio_node_state: AUDIO_NODE_STATE_STARTED if the node is started and its scheduled times overlap the range, otherwise AUDIO_NODE_STATE_STOPPED.
