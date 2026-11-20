# set_timed_fade_in_milliseconds
Schedule a fade of the sound's volume, with its length and start time in milliseconds.

`void sound::set_timed_fade_in_milliseconds(float start_volume, float end_volume, uint64 length, uint64 absolute_time);`

## Arguments:
* float start_volume: the volume to start from as a linear gain, or a negative number for the current volume.
* float end_volume: the volume to end at as a linear gain.
* uint64 length: how long the fade takes in milliseconds.
* uint64 absolute_time: when it starts on the engine's clock, in milliseconds.

## Remarks:
This is the same as `set_timed_fade()` but always measures in milliseconds.
