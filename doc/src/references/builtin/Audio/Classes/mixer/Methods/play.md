# play
Start playing the mixer, or start it again after `stop()`.

`bool mixer::play(bool reset_loop_state = true);`

## Arguments:
* bool reset_loop_state = true: if true, turn off looping, so that a sound that was playing looped plays to its end once. Pass false to keep it looping.

## Returns:
bool: true if the mixer started playing, false otherwise.

## Remarks:
A mixer is already playing when it is created, so this is only needed after it has been stopped. A sound plays from its current position, so it continues where it was paused, or from the start if it was stopped or played to its end.
