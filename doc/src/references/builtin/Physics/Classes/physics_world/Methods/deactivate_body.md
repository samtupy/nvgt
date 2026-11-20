# deactivate_body
Put a body to sleep.

`void physics_world::deactivate_body(const physics_body_id&in id);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Remarks:
A sleeping body does not move or cost anything to simulate until it is touched by an awake body or activated.
