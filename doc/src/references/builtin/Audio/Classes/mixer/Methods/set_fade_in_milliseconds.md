# set_fade_in_milliseconds
Fade the volume of the mixer from one level to another over a number of milliseconds.

`void mixer::set_fade_in_milliseconds(float start_volume, float end_volume, uint64 length_ms);`

## Arguments:
* float start_volume: the volume to start the fade from, or FLOAT_MAX for the current volume of the fade.
* float end_volume: the volume to end at.
* uint64 length_ms: how long the fade takes in milliseconds.

## Remarks:
This is the same as `set_fade()`, but always measures the length in milliseconds.
