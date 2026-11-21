# get_max_angular_velocity
Get the fastest a body can spin.

`float physics_world::get_max_angular_velocity(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
float: the limit in radians per second.

## Remarks:
The default is about 47 radians per second, a little over seven turns.
