# set_motion_type
Change whether a body is static, kinematic or dynamic.

`void physics_world::set_motion_type(const physics_body_id&in id, physics_body_type type, physics_activation activation = PHYSICS_ACTIVATE);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* physics_body_type type: the new motion type.
* physics_activation activation = PHYSICS_ACTIVATE: whether to wake the body up.

## Remarks:
Changing a body to static freezes it where it is, and changing it back to dynamic lets it fall again, which is how you could make an object pick up-able. Remember that static bodies should be in the non moving layer, so a body that will ever be moved should be created in the moving layer.
