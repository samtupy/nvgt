# add_force
Push a body for the duration of the next update.

1. `void physics_world::add_force(const physics_body_id&in id, const vector&in force);`
2. `void physics_world::add_force(const physics_body_id&in id, const vector&in force, const vector&in point);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in force: the force in newtons, which for a body of 1 kilogram accelerates it by 1 meter per second squared.
* const vector&in point (2): the point in the world to push at. A push away from the body's center of mass also turns it. Without this the push goes through the center of mass.

## Remarks:
A force acts for a single update and is then forgotten, so to keep pushing something, such as with an engine, call this every frame before `update()`. For a sudden push such as an explosion or a jump, use `add_impulse()`.
