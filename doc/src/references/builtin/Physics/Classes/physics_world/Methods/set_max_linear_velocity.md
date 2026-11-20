# set_max_linear_velocity
Limit how fast a body can move.

`void physics_world::set_max_linear_velocity(const physics_body_id&in id, float v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* float v: the speed limit in meters per second.

## Remarks:
A body that is going faster than this is slowed to the limit. Very fast bodies can pass through thin ones, so it can help to lower this.
