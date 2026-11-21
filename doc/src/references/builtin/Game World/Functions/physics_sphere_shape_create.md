# physics_sphere_shape_create
Create a sphere shape.

`physics_sphere_shape@ physics_sphere_shape_create(float radius, physics_material@ mat = null);`

## Arguments:
* float radius: the radius of the sphere in meters.
* physics_material@ mat = null: the material of the shape, which gives bodies made from the shape their friction and restitution, and determines how it absorbs, scatters and lets through sound in acoustic simulations such as sound_environment, see `physics_material_get()`. If null, the default material is used.

## Returns:
physics_sphere_shape@: the new shape, or null if it could not be created, such as when a size is not positive.

## Remarks:
A sphere is the cheapest shape to simulate and rolls realistically, which makes it good for balls, grenades and other small projectiles.
