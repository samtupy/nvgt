# play_looped
Start playing the mixer, repeating from the start every time it reaches its end.

`bool mixer::play_looped();`

## Returns:
bool: true if the mixer started playing, false otherwise.

## Remarks:
Looping only matters to a sound, as a mixer has no end. A sound that is being fed audio with `sound::stream_pcm()` can't be looped, and this returns false.
