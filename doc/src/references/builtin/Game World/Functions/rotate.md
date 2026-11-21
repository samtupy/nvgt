# rotate
Rotate a point around another on the x y plane.

`vector@ rotate(const vector&in point, const vector&in origin, double theta, bool maintain_z = true);`

## Arguments:
* const vector&in point: the point to rotate.
* const vector&in origin: the point to rotate around.
* double theta: the angle to rotate by in radians, counterclockwise.
* bool maintain_z = true: whether to keep the point's z coordinate. If false, the result's z is 0.

## Returns:
vector@: the rotated point.
