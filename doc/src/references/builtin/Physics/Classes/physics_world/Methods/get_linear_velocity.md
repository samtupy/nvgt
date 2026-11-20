# get_linear_velocity
Get how fast and in which direction a body is moving.

`vector@ physics_world::get_linear_velocity(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
vector@: the velocity in meters per second.
