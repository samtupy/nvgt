# pause_fade_in_frames
Fade the sound out over a number of PCM frames and then pause it.

`bool sound::pause_fade_in_frames(const uint64 length_in_frames);`

## Arguments:
* const uint64 length_in_frames: how long the fade takes in PCM frames.

## Returns:
bool: true if the fade was started.

## Remarks:
This is the same as `pause_fade()` but always measures the length in frames.
