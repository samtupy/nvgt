# physics_shape_sub_type
This is a list of the specific kinds of shapes, the value of `physics_shape::sub_type`.

* PHYSICS_SHAPE_SPHERE: a ball.
* PHYSICS_SHAPE_BOX: a box.
* PHYSICS_SHAPE_TRIANGLE: a single triangle.
* PHYSICS_SHAPE_CAPSULE: a cylinder with half spheres on the ends.
* PHYSICS_SHAPE_CYLINDER: a cylinder.
* PHYSICS_SHAPE_TAPERED_CAPSULE: a capsule whose ends have different radii.
* PHYSICS_SHAPE_TAPERED_CYLINDER: a cylinder whose ends have different radii.
* PHYSICS_SHAPE_CONVEX_HULL: the smallest convex shape that contains a set of points.
* PHYSICS_SHAPE_STATIC_COMPOUND: a shape made of several others that does not change.
* PHYSICS_SHAPE_MUTABLE_COMPOUND: a shape made of several others that can change.
* PHYSICS_SHAPE_MESH_SUBTYPE: a shape made of triangles.
* PHYSICS_SHAPE_HEIGHT_FIELD_SUBTYPE: a shape made of a grid of heights.
* PHYSICS_SHAPE_ROTATED_TRANSLATED: another shape turned and moved.
* PHYSICS_SHAPE_SCALED: another shape stretched, as made by `physics_shape::scaled()`.
* PHYSICS_SHAPE_OFFSET_CENTER_OF_MASS: another shape whose center of mass is moved.
* PHYSICS_SHAPE_PLANE_SUBTYPE: a flat surface that is solid behind it.

Currently the shape creation functions make the sphere, box, capsule, cylinder, tapered capsule, tapered cylinder and plane shapes, and `physics_shape::scaled()` makes scaled shapes.
