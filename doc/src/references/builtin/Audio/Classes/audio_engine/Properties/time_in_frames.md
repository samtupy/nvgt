# time_in_frames
How long the engine has been running, in PCM frames.

`const uint64 audio_engine::time_in_frames;`

## Remarks:
The time advances as the engine produces audio, and can be set with `set_time_in_frames()`.
