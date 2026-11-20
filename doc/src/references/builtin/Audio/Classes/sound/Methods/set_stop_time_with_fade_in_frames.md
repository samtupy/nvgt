# set_stop_time_with_fade_in_frames
Schedule the sound to fade out and stop, with times in PCM frames.

`void sound::set_stop_time_with_fade_in_frames(uint64 absolute_time, uint64 fade_length);`

## Arguments:
* uint64 absolute_time: when the sound should have stopped on the engine's clock, in frames.
* uint64 fade_length: how long the fade takes in frames.

## Remarks:
This is the same as `set_stop_time_with_fade()` but always measures in frames.
