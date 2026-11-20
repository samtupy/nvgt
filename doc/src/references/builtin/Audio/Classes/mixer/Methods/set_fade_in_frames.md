# set_fade_in_frames
Fade the volume of the mixer from one level to another over a number of PCM frames.

`void mixer::set_fade_in_frames(float start_volume, float end_volume, uint64 length_frames);`

## Arguments:
* float start_volume: the volume to start the fade from, or FLOAT_MAX for the current volume of the fade.
* float end_volume: the volume to end at.
* uint64 length_frames: how long the fade takes in PCM frames.

## Remarks:
This is the same as `set_fade()`, but always measures the length in frames.
