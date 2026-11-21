# add_impulse
Give a body a sudden push.

1. `void physics_world::add_impulse(const physics_body_id&in id, const vector&in impulse);`
2. `void physics_world::add_impulse(const physics_body_id&in id, const vector&in impulse, const vector&in point);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in impulse: the impulse in kilogram meters per second. The velocity the body gains is this divided by its mass.
* const vector&in point (2): the point in the world to push at, which can also make the body spin.

## Remarks:
An impulse changes the body's velocity immediately and once, unlike a force which acts over the next update.
