# add_angular_impulse
Give a body a sudden spin.

`void physics_world::add_angular_impulse(const physics_body_id&in id, const vector&in impulse);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in impulse: the angular impulse, whose direction is the axis the body starts to turn around.

## Remarks:
This changes the body's angular velocity immediately and once.
