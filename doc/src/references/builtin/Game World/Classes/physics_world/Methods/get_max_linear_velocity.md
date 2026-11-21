# get_max_linear_velocity
Get the fastest a body can move.

`float physics_world::get_max_linear_velocity(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
float: the speed limit in meters per second.

## Remarks:
The default is 500.
