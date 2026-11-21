# set_rotation
Turn a body to a rotation.

`void physics_world::set_rotation(const physics_body_id&in id, const quaternion&in rot, physics_activation activation = PHYSICS_ACTIVATE);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const quaternion&in rot: the new rotation.
* physics_activation activation = PHYSICS_ACTIVATE: whether to wake the body up.
