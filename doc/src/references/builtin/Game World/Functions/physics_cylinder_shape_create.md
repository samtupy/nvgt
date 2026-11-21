# physics_cylinder_shape_create
Create a cylinder shape.

`physics_cylinder_shape@ physics_cylinder_shape_create(float half_height, float radius, float convex_radius = 0.05f, physics_material@ mat = null);`

## Arguments:
* float half_height: half of the height of the cylinder.
* float radius: the radius of the cylinder.
* float convex_radius = 0.05f: how much the edges are rounded, see `physics_box_shape_create()`.
* physics_material@ mat = null: the material of the shape, which gives bodies made from the shape their friction and restitution, and determines how it absorbs, scatters and lets through sound in acoustic simulations such as sound_environment, see `physics_material_get()`. If null, the default material is used.

## Returns:
physics_cylinder_shape@: the new shape, or null if it could not be created, such as when a size is not positive.

## Remarks:
Like a capsule, a cylinder stands along the y axis of the shape, so rotate its body to stand it up in a z up world. Cylinders suit barrels, pillars and wheels.
