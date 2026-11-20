# max_distance
The distance from the listener at which the mixer becomes silent.

`float mixer::max_distance;`

## Remarks:
The default is 50. The volume is faded smoothly towards silence as the mixer approaches this distance, and beyond it the mixer is at `min_gain`. Set it to the distance at which sounds should stop being heard, which for a large map might be much further than the default.
