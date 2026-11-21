# add_torque
Twist a body for the duration of the next update.

`void physics_world::add_torque(const physics_body_id&in id, const vector&in torque);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in torque: the torque in newton meters, whose direction is the axis to turn around.

## Remarks:
Like `add_force()`, a torque acts for a single update and is then forgotten, so apply it every frame to keep spinning something. For a sudden spin use `add_angular_impulse()`.
