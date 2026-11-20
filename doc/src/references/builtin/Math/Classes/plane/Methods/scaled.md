# scaled
Get a copy of the plane as it would be if all of space were stretched by different amounts along each axis.

`plane@ plane::scaled(const vector&in scale) const;`

## Arguments:
* const vector&in scale: how much to stretch along the x, y and z axes, where 1 is no change and a negative value mirrors along that axis.

## Returns:
plane@: the scaled plane. The plane this is called on is not changed.

## Remarks:
Points that were on the plane are on the scaled plane once each of their coordinates is multiplied by the scale, so a plane at a height of 1 scaled by `vector(1, 1, 2)` is at a height of 2. No part of the scale may be 0.
