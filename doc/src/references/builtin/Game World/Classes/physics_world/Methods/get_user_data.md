# get_user_data
Retrieve the value attached to a body with `set_user_data()`.

`any@ physics_world::get_user_data(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
any@: the stored value, or null if there is none.
