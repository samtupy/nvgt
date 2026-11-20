# physics_shape
A physics_shape describes the form of a body, which decides what it collides with. It is made with one of the `physics_*_shape_create()` functions, such as `physics_box_shape_create()`, and given to `physics_world::create_and_add_body()`, and the same shape may be given to any number of bodies.

Each kind of shape has its own class that is derived from physics_shape, most of them through physics_convex_shape, so a shape such as a physics_box_shape has all the properties of the classes it derives from. Handles can be cast between them, `cast<physics_box_shape>(shape)` returning null if the shape is of a different kind, and a shape of any kind may be passed where a physics_shape is expected.

The kinds of shape are:
* physics_sphere_shape: a ball, with a `radius`.
* physics_box_shape: a box, with a `half_extent`.
* physics_capsule_shape: a cylinder with half spheres on its ends, with a `half_height` and a `radius`.
* physics_cylinder_shape: a cylinder with a `half_height` and a `radius`.
* physics_tapered_capsule_shape: a capsule whose ends have a `top_radius` and a `bottom_radius`.
* physics_tapered_cylinder_shape: a cylinder whose ends have a `top_radius` and a `bottom_radius`.
* physics_plane_shape: a flat surface with a `plane`, that is solid behind it, which is good for floors.

All of these but the plane are convex, meaning that they have no dents, and are derived from physics_convex_shape. A plane shape can only be used for static and kinematic bodies. Any shape can also be stretched into a new physics_shape with `scaled()`. Shapes are measured in meters. Shapes whose size is described along an axis, the capsule and cylinders, are aligned with the y axis of the shape, and a body that is to stand up in the world, where z is up, needs a rotation to do so, such as `quaternion_from_axis_angle(vector(1, 0, 0), 1.5707964)`.

The properties that are specific to each kind of shape are listed in the documentation of the creation function of that kind.
