# get_center_of_mass_position
Get the position of a body's center of mass.

`vector@ physics_world::get_center_of_mass_position(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
vector@: the position in the world.

## Remarks:
This differs from `get_position()` for shapes that aren't centered on their origin. It is where forces act on the body when they are applied without a point.
