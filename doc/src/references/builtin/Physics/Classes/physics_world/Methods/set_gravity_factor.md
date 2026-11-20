# set_gravity_factor
Set how strongly gravity affects a body.

`void physics_world::set_gravity_factor(const physics_body_id&in id, float v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* float v: the factor the world's gravity is multiplied by for this body. 1 is normal, 0 makes the body float, and a negative value makes it fall upwards.
