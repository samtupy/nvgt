# physics_shape_type
This is a list of the general categories a shape can be in, the value of `physics_shape::type`.

* PHYSICS_SHAPE_CONVEX: a shape without dents, such as a sphere, box, capsule or cylinder.
* PHYSICS_SHAPE_COMPOUND: a shape made of several others.
* PHYSICS_SHAPE_MESH: a shape made of triangles.
* PHYSICS_SHAPE_HEIGHT_FIELD: a shape made of a grid of heights, such as terrain.
* PHYSICS_SHAPE_DECORATED: a shape that changes another, such as one made by `physics_shape::scaled()`.
* PHYSICS_SHAPE_PLANE: a flat surface that is solid behind it, made by `physics_plane_shape_create()`.
