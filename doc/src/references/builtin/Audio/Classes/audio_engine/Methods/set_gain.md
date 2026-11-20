# set_gain
Set the master gain of the engine in decibels.

`bool audio_engine::set_gain(float gain);`

## Arguments:
* float gain: the gain in decibels, where 0 is unchanged.

## Returns:
bool: true if the gain was set.

## Remarks:
The current value is available as the `gain` property. This is combined with `volume`.
