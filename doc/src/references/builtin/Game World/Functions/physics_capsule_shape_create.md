# physics_capsule_shape_create
Create a capsule shape, a cylinder with a half sphere on each end.

`physics_capsule_shape@ physics_capsule_shape_create(float half_height, float radius, physics_material@ mat = null);`

## Arguments:
* float half_height: half of the height of the straight part between the two ends, so the whole capsule is `2 * half_height + 2 * radius` tall.
* float radius: the radius of the capsule.
* physics_material@ mat = null: the material of the shape, which gives bodies made from the shape their friction and restitution, and determines how it absorbs, scatters and lets through sound in acoustic simulations such as sound_environment, see `physics_material_get()`. If null, the default material is used.

## Returns:
physics_capsule_shape@: the new shape, or null if it could not be created, such as when a size is not positive.

## Remarks:
A capsule stands along the y axis of the shape, so to make one stand up in the world, where z is up, give its body a rotation of 90 degrees around the x axis such as `quaternion_from_axis_angle(vector(1, 0, 0), 1.5707964)`. Capsules are a very good approximation of a standing person, since they slide smoothly along walls and up steps.
