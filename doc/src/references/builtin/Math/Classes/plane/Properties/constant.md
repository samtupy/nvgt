# constant
The negative of the plane's distance from the origin along its normal.

`float plane::constant;`

## Remarks:
A plane facing up with a constant of -2 is at a height of 2, and one with a constant of 2 is at a height of -2. The plane is the set of points for which `point.dot(normal) + constant` is 0.
