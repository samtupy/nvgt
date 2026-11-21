# get_angular_velocity
Get how fast and around which axis a body is spinning.

`vector@ physics_world::get_angular_velocity(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
vector@: the axis of the spin, whose length is the speed in radians per second.
