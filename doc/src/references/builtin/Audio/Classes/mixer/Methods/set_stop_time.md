# set_stop_time
Schedule the mixer to stop playing at a time on the engine's clock.

`void mixer::set_stop_time(uint64 absolute_time);`

## Arguments:
* uint64 absolute_time: the time on the engine's clock, see `audio_engine::time_in_milliseconds` and `audio_engine::time_in_frames`, at which to stop. This is in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.

## Remarks:
See also `start_time`.
