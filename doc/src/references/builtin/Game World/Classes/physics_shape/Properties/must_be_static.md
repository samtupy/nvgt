# must_be_static
Whether the shape can't be used for dynamic bodies.

`const bool physics_shape::must_be_static;`

## Remarks:
This is true for plane shapes and anything made from them. `physics_world::create_and_add_body()` fails when such a shape is given with PHYSICS_BODY_DYNAMIC.
