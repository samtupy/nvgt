# set_position_and_rotation
Move and turn a body in one go.

`void physics_world::set_position_and_rotation(const physics_body_id&in id, const vector&in pos, const quaternion&in rot, physics_activation activation = PHYSICS_ACTIVATE);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in pos: the new position.
* const quaternion&in rot: the new rotation.
* physics_activation activation = PHYSICS_ACTIVATE: whether to wake the body up.
