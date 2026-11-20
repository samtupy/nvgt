# local_bounds
The smallest box that contains the shape, around the shape's own origin.

`const aabb physics_shape::local_bounds;`

## Remarks:
This is not rotated or moved, for the box of a body in the world use `physics_world::get_world_space_bounds()`.
