# set_linear_velocity
Set how fast and in which direction a body is moving.

`void physics_world::set_linear_velocity(const physics_body_id&in id, const vector&in v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in v: the new velocity in meters per second.

## Remarks:
This replaces the body's velocity, including any it gained from falling. To add to it instead, use `add_linear_velocity()` or the force and impulse methods.
