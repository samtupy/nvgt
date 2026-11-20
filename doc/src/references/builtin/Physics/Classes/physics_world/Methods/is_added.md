# is_added
Check whether a body is currently part of the simulation.

`bool physics_world::is_added(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
bool: true if the body has been added to the world and not removed.
