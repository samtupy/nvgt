# set_volume
Set the master volume of the engine.

`bool audio_engine::set_volume(float volume);`

## Arguments:
* float volume: a linear multiplier, where 1 is full volume and 0 is silent.

## Returns:
bool: true if the volume was set.

## Remarks:
The current value is available as the `volume` property.
