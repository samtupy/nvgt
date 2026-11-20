# physics_object_layer
This is a list of the layers a body can be put in, passed to `physics_world::create_and_add_body()`. Layers decide which bodies need to be checked against each other for collisions.

* PHYSICS_LAYER_NON_MOVING: for static bodies. Bodies in this layer collide only with those in the moving layer, never with each other, so a large static level costs very little.
* PHYSICS_LAYER_MOVING: for kinematic and dynamic bodies, which collide with everything.

A static body must be in the non moving layer, and a body that moves, or may be changed to move with `physics_world::set_motion_type()`, in the moving layer.
