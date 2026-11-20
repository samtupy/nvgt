# length
The length of the sound.

`const uint64 sound::length;`

## Remarks:
This is in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames. It is 0 if nothing is loaded or the length isn't known, such as for a live stream, and may be 0 until a sound loaded with `load()` has finished decoding.
