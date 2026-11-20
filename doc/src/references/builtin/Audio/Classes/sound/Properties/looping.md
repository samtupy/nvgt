# looping
Whether the sound starts again from the beginning when it reaches its end.

`bool sound::looping;`

## Remarks:
`play_looped()` sets this to true, and `play()` sets it back to false unless told not to. A sound streamed with `stream_pcm()` can't loop.
