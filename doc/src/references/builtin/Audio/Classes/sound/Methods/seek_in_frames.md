# seek_in_frames
Move the sound to a position given in PCM frames.

`bool sound::seek_in_frames(const uint64 position);`

## Arguments:
* const uint64 position: the frame to move to.

## Returns:
bool: true if the sound was moved.

## Remarks:
This is the same as `seek()` but always measures in frames.
