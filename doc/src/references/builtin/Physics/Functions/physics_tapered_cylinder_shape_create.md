# physics_tapered_cylinder_shape_create
Create a cylinder shape whose two ends have different radii, a cone with the top cut off when one is small.

`physics_tapered_cylinder_shape@ physics_tapered_cylinder_shape_create(float half_height, float top_radius, float bottom_radius, float convex_radius = 0.05f, physics_material@ mat = null);`

## Arguments:
* float half_height: half of the height of the shape.
* float top_radius: the radius of the flat end at the top (the positive y axis of the shape).
* float bottom_radius: the radius of the flat end at the bottom.
* float convex_radius = 0.05f: how much the edges are rounded, see `physics_box_shape_create()`. It must not be larger than the smaller radius.
* physics_material@ mat = null: the material of the shape, see `physics_material_get()`. If null, the default material is used.

## Returns:
physics_tapered_cylinder_shape@: the new shape, or null if it could not be created, such as when a size is not positive.

## Remarks:
Like a cylinder, it stands along the y axis of the shape. Use it for shapes such as buckets, lamp shades and traffic cones.
