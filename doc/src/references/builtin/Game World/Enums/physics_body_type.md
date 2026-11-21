# physics_body_type
This is a list of the ways a body can move, passed to `physics_world::create_and_add_body()`, `physics_world::set_motion_type()` and returned by `physics_world::get_motion_type()`.

* PHYSICS_BODY_STATIC: the body never moves, and costs nothing to simulate. Use it for floors, walls and the rest of a level.
* PHYSICS_BODY_KINEMATIC: the body is moved only by your script, using `physics_world::move_kinematic()` or `physics_world::set_position()`, and is not affected by gravity or collisions, but pushes dynamic bodies. Use it for moving platforms and doors.
* PHYSICS_BODY_DYNAMIC: the body is moved by the simulation, falling under gravity and bouncing off or pushing the bodies it collides with.
