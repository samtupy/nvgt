# set_max_angular_velocity
Limit how fast a body can spin.

`void physics_world::set_max_angular_velocity(const physics_body_id&in id, float v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* float v: the limit in radians per second.
