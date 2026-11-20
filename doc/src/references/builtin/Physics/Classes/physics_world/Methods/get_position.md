# get_position
Get the position of a body.

`vector@ physics_world::get_position(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
vector@: the position of the body's origin in the world.
