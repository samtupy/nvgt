# stop
Stop playing the mixer.

`bool mixer::stop();`

## Returns:
bool: true if the mixer was stopped, false otherwise.

## Remarks:
Everything in a stopped mixer is silent until it is played again, though the sounds in it carry on playing. Stopping a sound also moves it back to its start, use `sound::pause()` to keep its position.
