# get_gravity_factor
Get how strongly gravity affects a body.

`float physics_world::get_gravity_factor(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
float: the factor, where 1 is normal gravity.
