# rolloff
How quickly the mixer gets quieter as it moves away from the listener.

`float mixer::rolloff;`

## Remarks:
The default is 0.375. Beyond `min_distance` the volume drops by 1.75 decibels per unit of distance for each unit of rolloff, so the default keeps a mixer at just under half volume 10 units away and a fifth of its volume 20 units away. Whatever the rolloff, the volume fades smoothly to silence at `max_distance`. A rolloff of 0 doesn't make the mixer quieter with distance at all until it nears `max_distance`.
