# set_state_time
Schedule when the node starts or stops.

`bool audio_node::set_state_time(audio_node_state state, uint64 time);`

## Arguments:
* audio_node_state state: which transition to schedule.
* uint64 time: the time on the engine's global clock, in PCM frames, at which the node enters this state.

## Returns:
bool: true if the time was set.

## Remarks:
Setting the time of the started state delays the node's start until then, and setting that of the stopped state makes the node stop by itself when the time arrives, which gives sample accurate scheduling of sounds. The current time on that clock is available as `audio_engine::time_in_frames`.
