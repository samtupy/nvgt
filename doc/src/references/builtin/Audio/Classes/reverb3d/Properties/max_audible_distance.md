# max_audible_distance
The distance from the listener at which the reverb of a sound has faded out.

`float reverb3d::max_audible_distance;`

## Remarks:
The default is 60. At this distance and beyond, a sound is sent to the reverb at -60 decibels, which is all but silent. Set it to around the distance at which your sounds themselves stop being heard, so that the reverb of a distant sound doesn't outlast the sound.
