# seek_in_milliseconds
Move the sound to a position given in milliseconds.

`bool sound::seek_in_milliseconds(const uint64 position);`

## Arguments:
* const uint64 position: the position to move to in milliseconds.

## Returns:
bool: true if the sound was moved.

## Remarks:
This is the same as `seek()` but always measures in milliseconds.
