# pan
The position of the mixer between the left and right speakers, for audio that isn't positioned in 3d.

`float mixer::pan;`

## Remarks:
In the default engine this goes from -100 for fully left to 100 for fully right, and in an engine you create from -1 to 1. 0 is centered. Pan is not meant to be combined with `set_position_3d()`, which pans the mixer itself. See also `pan_mode`.
