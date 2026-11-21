# activate_body
Wake a body up.

`void physics_world::activate_body(const physics_body_id&in id);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Remarks:
Sleeping bodies wake automatically when something touches them, but not when you take away what they were resting on without telling the simulation.
