# is_valid_scale
Check whether the shape can be stretched by a scale exactly, without making a compound of several shapes.

`bool physics_shape::is_valid_scale(const vector&in scale) const;`

## Arguments:
* const vector&in scale: how much to stretch along the x, y and z axes, where 1 is no change.

## Returns:
bool: true if `scaled()` can stretch the shape by this scale directly.

## Remarks:
Spheres and capsules can only be scaled by the same amount along every axis, cylinders can only be scaled by the same amount along x and z, and boxes can be scaled any way. No part of a scale may be 0.
