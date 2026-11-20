# set_shape
Change the shape of a body.

`void physics_world::set_shape(const physics_body_id&in id, physics_shape@ shape, bool update_mass = true, physics_activation activation = PHYSICS_ACTIVATE);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* physics_shape@ shape: the new shape.
* bool update_mass = true: whether to recalculate the body's mass and the way it spins from the new shape. Leave this on unless you want to keep the old mass.
* physics_activation activation = PHYSICS_ACTIVATE: whether to wake the body up.

## Remarks:
This is how a body grows, shrinks or changes form, such as a crate that breaks. Other bodies resting on a body whose shape changes are not woken up automatically. Nothing happens if the shape is null.
