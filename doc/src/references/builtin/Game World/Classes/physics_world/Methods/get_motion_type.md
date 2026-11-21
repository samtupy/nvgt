# get_motion_type
Get whether a body is static, kinematic or dynamic.

`physics_body_type physics_world::get_motion_type(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
physics_body_type: the motion type of the body.
