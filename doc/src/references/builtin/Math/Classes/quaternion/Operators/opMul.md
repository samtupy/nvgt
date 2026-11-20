# opMul
Overloads the * operator, combining two rotations or rotating a vector.

1. `quaternion@ quaternion::opMul(const quaternion&in other) const;`
2. `vector@ quaternion::opMul(const vector&in v) const;`

## Arguments:
* const quaternion&in other (1): the rotation to apply first.
* const vector&in v (2): the vector to rotate.

## Returns:
quaternion@ (1): the combined rotation.

vector@ (2): the rotated vector.

## Remarks:
The result of combining rotations depends on their order. In `a * b`, b is applied first and then a.
