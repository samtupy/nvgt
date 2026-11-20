# get_rotation
Get the rotation of a body.

`quaternion@ physics_world::get_rotation(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
quaternion@: the rotation of the body.
