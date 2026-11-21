# is_active
Check whether a body is awake.

`bool physics_world::is_active(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
bool: true if the body is awake, false if it is asleep or removed from the world.

## Remarks:
Bodies fall asleep once they stop moving. See also `num_active_bodies`.
