# set_mixer
Put the mixer into another mixer, or take it out of one.

`bool mixer::set_mixer(mixer@+ parent_mixer);`

## Arguments:
* mixer@+ parent_mixer: the mixer to send this one's audio to, or null to send it straight to the engine's output.

## Returns:
bool: true if the mixer was moved, false if it was already in that mixer or the connection could not be made.

## Remarks:
The parent's volume, pitch, effects and position then apply to this mixer as well. Never put a mixer into itself or into one of the mixers inside it, which makes a loop that the engine can't play.
