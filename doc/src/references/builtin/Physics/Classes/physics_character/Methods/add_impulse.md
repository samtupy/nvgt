# add_impulse
Give the character a sudden push.

`void physics_character::add_impulse(const vector&in impulse);`

## Arguments:
* const vector&in impulse: the impulse in kilogram meters per second. The speed the character gains is this divided by its mass.

## Remarks:
A jump can be made by an impulse in the up direction.
