# start_time
Schedule the mixer to start playing at a time on the engine's clock.

`uint64 mixer::start_time;`

## Remarks:
The time is on the engine's clock, see `audio_engine::time_in_milliseconds` and `audio_engine::time_in_frames`, and is in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames. This property can only be set, not read. Call `play()` as usual, and the mixer only becomes audible at the given time, which lets sounds be started in time with each other or with music more precisely than calling `play()` at the right moment.
