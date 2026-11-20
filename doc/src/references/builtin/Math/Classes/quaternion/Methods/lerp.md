# lerp
Interpolate between this rotation and another in a straight line.

`quaternion@ quaternion::lerp(const quaternion&in dest, float t) const;`

## Arguments:
* const quaternion&in dest: the rotation to move towards.
* float t: how far to move, from 0 for this rotation to 1 for dest.

## Returns:
quaternion@: the rotation in between.

## Remarks:
This is faster than `slerp()` and fine for small differences, but the speed of the rotation is not constant.
