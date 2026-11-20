# set_stop_time_with_fade_in_milliseconds
Schedule the sound to fade out and stop, with times in milliseconds.

`void sound::set_stop_time_with_fade_in_milliseconds(uint64 absolute_time, uint64 fade_length);`

## Arguments:
* uint64 absolute_time: when the sound should have stopped on the engine's clock, in milliseconds.
* uint64 fade_length: how long the fade takes in milliseconds.

## Remarks:
This is the same as `set_stop_time_with_fade()` but always measures in milliseconds.
