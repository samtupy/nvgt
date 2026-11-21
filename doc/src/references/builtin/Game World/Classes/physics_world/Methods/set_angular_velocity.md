# set_angular_velocity
Set how fast and around which axis a body is spinning.

`void physics_world::set_angular_velocity(const physics_body_id&in id, const vector&in v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in v: the axis of the spin, whose length is the speed in radians per second.
