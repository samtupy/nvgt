# remove_and_destroy_body
Remove a body from the world and free it.

`void physics_world::remove_and_destroy_body(const physics_body_id&in id);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Remarks:
This is how you delete a body, such as when a crate is destroyed or a monster dies. The id can't be used again afterwards.
