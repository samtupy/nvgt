# destroy_body
Free a body that has already been removed from the world.

`void physics_world::destroy_body(const physics_body_id&in id);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Remarks:
The body must have been removed with `remove_body()` first, and its id can't be used again afterwards. Any user data attached to the body is released.
