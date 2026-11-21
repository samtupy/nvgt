# physics_world
A physics_world is a simulation of rigid bodies, solid objects that fall, collide, bounce and slide, that you step forward in time from your game loop. It is NVGT's wrapper around the Jolt physics engine, and can also be used as the world that sound_environment (from the nvgt_phonon plugin) traces its occlusion and reflections through.

`physics_world@ physics_world(uint max_bodies = 1024, uint max_body_pairs = 1024, uint max_contact_constraints = 1024);`

## Arguments:
* uint max_bodies = 1024: the most bodies that can exist in the world at once, including static ones such as walls. Adding a body beyond this fails.
* uint max_body_pairs = 1024: the most pairs of bodies that may be close enough to need a collision check in one update. Raise this if you have many bodies packed together.
* uint max_contact_constraints = 1024: the most contacts that may be resolved in a single update. Raise this if you have many bodies resting on or against each other.

## Remarks:
The three limits are reserved when the world is created, so there is no point in making them much larger than you need, but if they are too low bodies will be missing or will pass through each other with no error. Worlds that model a few characters and a level are fine with the defaults, while a world with thousands of objects needs a lot more.

### The basics
A world is made of bodies. A body is a shape (a sphere, box, capsule or cylinder, see for example `physics_box_shape_create()`) that has a position and rotation and a motion type from the `physics_body_type` enum:
* PHYSICS_BODY_STATIC bodies never move, which makes them cheap and is what you want for floors, walls and other parts of a level.
* PHYSICS_BODY_DYNAMIC bodies are moved by the simulation, which pulls them down with gravity and pushes them around when they collide. Use them for crates, balls, debris and anything else that should obey physics.
* PHYSICS_BODY_KINEMATIC bodies are moved only by your script, with `move_kinematic()` or `set_position()`, but they push dynamic bodies out of the way. Use them for things such as moving platforms and doors.

Bodies are not objects in your script. You get a physics_body_id back from `create_and_add_body()` and pass it to the world's methods to read or change the body, so keep the ids of any bodies you need to find again, and remove them with `remove_and_destroy_body()` when you are done.

Every body is also in a layer, either PHYSICS_LAYER_NON_MOVING for static bodies or PHYSICS_LAYER_MOVING for everything else. Non moving bodies are never checked against each other, which saves a great deal of work, so a static body should always be in the non moving layer.

### Units and directions
Distances are in meters, time in seconds and mass in kilograms, though you are free to treat a unit as something else in your game as long as you are consistent, and gravity, speeds and forces are scaled to match. NVGT uses a z up coordinate system, with x to the right, y forward and z up, so a new world's gravity points down the z axis, `(0, 0, -9.81)`, which is that of the earth in meters per second squared. Change it with the `gravity` property.

### Running the simulation
Nothing moves until you call `update()` with the time that has passed, normally once per frame of your game loop. For stable results the time should be small, so a delta of more than about 1/60th of a second should be split over multiple collision steps, or the update called several times. Bodies that come to rest go to sleep and cost almost nothing until something touches them, see the `num_active_bodies` property.

To find out when bodies hit each other, call `set_contact_listener()`, whose callbacks run during `update()` on the thread that called it. To find what is in a direction from a point, use `cast_ray()`.

## Example:
```
void main() {
	physics_world world;
	// A floor 1 meter thick, whose top is at z 0, which never moves.
	world.create_and_add_body(physics_box_shape_create(vector(50, 50, 0.5)), vector(0, 0, -0.5), IDENTITY_QUATERNION, PHYSICS_BODY_STATIC, PHYSICS_LAYER_NON_MOVING);
	// A ball with a radius of half a meter dropped from 10 meters up.
	physics_body_id ball = world.create_and_add_body(physics_sphere_shape_create(0.5), vector(0, 0, 10), IDENTITY_QUATERNION, PHYSICS_BODY_DYNAMIC);
	for (int i = 0; i < 180; i++) world.update(1.0 / 60); // Three seconds of simulation.
	vector pos = world.get_position(ball);
	alert("Ball", "The ball came to rest at a height of " + pos.z);
}
```
