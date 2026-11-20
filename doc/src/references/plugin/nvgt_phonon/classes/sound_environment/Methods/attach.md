# attach
Attach an existing sound or mixer to this environment.

`bool sound_environment::attach(mixer@+ sound_or_mixer);`

## Arguments:
* mixer@+ sound_or_mixer: the sound or mixer to attach.

## Returns:
bool: true if the object is now attached to this environment, false otherwise.

## Remarks:
An object can only belong to one environment (or reverb3d) at a time, attaching it to this one removes it from the previous one. The environment is applied before the sound is panned, so that what it simulates is the sound itself.

Everything that plays through an attached mixer is covered by the mixer's simulation, including sounds that are added to it later.
