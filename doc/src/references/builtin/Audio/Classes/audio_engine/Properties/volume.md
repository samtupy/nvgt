# volume
The master volume of the engine.

`const float audio_engine::volume;`

## Remarks:
This is a linear multiplier, where 1 is full volume, and is read only. To change it call `set_volume()`. To make the engine louder than its normal level in decibels use `set_gain()`.
