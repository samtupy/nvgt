# seek
Move the sound to a position.

`bool sound::seek(const uint64 position);`

## Arguments:
* const uint64 position: the position to move to from the start of the sound, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.

## Returns:
bool: true if the sound was moved, false if nothing is loaded or the sound has no known length, such as a live stream.

## Remarks:
The sound carries on playing from the new position if it was playing. The move is made by the audio thread before it next reads the sound, which makes this safe to call while the sound plays, unlike seeking the sound's `datasource` directly.
