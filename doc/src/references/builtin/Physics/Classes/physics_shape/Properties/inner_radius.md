# inner_radius
The radius of the largest sphere that fits entirely inside the shape.

`const float physics_shape::inner_radius;`

## Remarks:
This is a measure of how far a body with the shape can safely move in one step without risking passing through something thin. A box with a half extent of `vector(1, 2, 3)` has an inner radius of 1, and a plane has an inner radius of 0.
