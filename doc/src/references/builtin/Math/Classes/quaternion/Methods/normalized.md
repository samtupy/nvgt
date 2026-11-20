# normalized
Get a copy of the quaternion with a length of 1.

`quaternion@ quaternion::normalized() const;`

## Returns:
quaternion@: the normalized quaternion.

## Remarks:
Repeatedly combining rotations can make a quaternion drift away from a length of 1, which makes it a distorted rotation. Normalizing it brings it back.
