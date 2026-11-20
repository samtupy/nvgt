# pause
Stop playing the sound, keeping its position so that `play()` continues from where it was.

`bool sound::pause();`

## Returns:
bool: true if the sound was paused, false if nothing is loaded or it is being streamed with `stream_pcm()`.

## Remarks:
`stop()` instead moves the sound back to its start.
