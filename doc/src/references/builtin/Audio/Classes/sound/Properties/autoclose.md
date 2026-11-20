# autoclose
Whether the sound is kept alive until it finishes playing after the last handle to it is released.

`bool sound::autoclose;`

## Remarks:
Normally a sound is destroyed and stops as soon as nothing refers to it. With autoclose on, it plays to its end first, which is how `sound_play()` lets you fire off a sound without keeping it in a variable. Sounds returned by `sound_play()` and `audio_engine::play()` have it turned on.
