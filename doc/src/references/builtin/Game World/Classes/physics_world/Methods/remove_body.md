# remove_body
Take a body out of the simulation without destroying it.

`void physics_world::remove_body(const physics_body_id&in id);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Remarks:
A removed body can't collide or move, and is no longer found by `cast_ray()`, but it still exists and still counts as one of the world's maximum bodies until it is destroyed with `destroy_body()`. In practice you will nearly always want `remove_and_destroy_body()`.
