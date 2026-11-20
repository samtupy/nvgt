# position
The current position of the sound.

`const uint64 sound::position;`

## Remarks:
This is in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames. Change it with `seek()`.
