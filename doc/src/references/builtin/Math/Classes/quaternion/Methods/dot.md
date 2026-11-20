# dot
Calculate the dot product of this quaternion and another.

`float quaternion::dot(const quaternion&in other) const;`

## Arguments:
* const quaternion&in other: the other quaternion.

## Returns:
float: the dot product, which is 1 for equal rotations and closer to 0 the more different they are.
