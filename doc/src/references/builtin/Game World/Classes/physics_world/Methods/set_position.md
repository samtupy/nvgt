# set_position
Move a body to a position.

`void physics_world::set_position(const physics_body_id&in id, const vector&in pos, physics_activation activation = PHYSICS_ACTIVATE);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in pos: the new position.
* physics_activation activation = PHYSICS_ACTIVATE: whether to wake the body up so that it reacts to its new surroundings.

## Remarks:
The body jumps there instantly without colliding with anything on the way, and keeps its velocity, so for a dynamic body you may want to `set_linear_velocity()` to zero as well. To move a kinematic body so that it pushes things along the way use `move_kinematic()` instead.
