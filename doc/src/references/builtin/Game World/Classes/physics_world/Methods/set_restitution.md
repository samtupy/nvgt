# set_restitution
Set how bouncy a body is.

`void physics_world::set_restitution(const physics_body_id&in id, float v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* float v: the restitution, where 0 means a body stops dead when it hits something and 1 means it bounces back with all the speed it came with.

## Remarks:
The default is 0.
