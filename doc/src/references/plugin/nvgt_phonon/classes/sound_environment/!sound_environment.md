# sound_environment
A sound_environment simulates how sound travels through a physical world, using Steam Audio, and applies the result to the sounds that are attached to it. For each attached sound it works out how much the direct sound is blocked by walls (occlusion), how much of it gets through them anyway and in which frequencies (transmission), and what the room sounds like, including echoes and reverb that depend on the shape and materials of the surroundings (reflections). It can also optionally let sound be heard bending around obstacles such as doorways (pathing), using paths baked ahead of time.

The world the sound travels through is provided by a raycaster, currently a physics_world, and the acoustic properties of its surfaces come from the physics_material of the bodies in it. This class is part of the nvgt_phonon plugin, so your script needs the line `#pragma plugin nvgt_phonon`.

`sound_environment@ sound_environment(audio_engine@+ engine = sound_default_engine);`

## Arguments:
* audio_engine@+ engine = sound_default_engine: the audio engine whose sounds the environment will process.

## Remarks:
An exception is thrown if Steam Audio could not be initialized.

The typical way to use an environment is:
1. Create it and give it a raycaster with `set_raycaster()` - usually that's a physics_world.
2. Create a mixer for each object in your world that makes sound with `new_mixer()` (or use `attach()` for existing sounds and mixers), and move each mixer with its object using `set_position_3d()`.
3. Play the object's sounds through its mixer.
4. Every frame, position the listener of the engine and call `update()`.

Sounds are positioned with the engine's usual 3D functions, and other than attenuation where the curve is less dramatic to acomidate audio games, the environment treats one unit of distance as one meter. Occlusion and transmission are simulated on every call to `update()`, while reflections are simulated on a background thread and therefore could get a little behind in a full scene. Reflections are not simulated for every sound separately but for a limited number of groups that nearby sounds share, see `max_sources` and `reflection_group_size`.

Each attached sound or mixer is given a sound_environment_source, retrievable with `get_source()`, with settings and simulation results for just that sound.

## Example:
```
void main() {
	physics_world world;
	// A concrete floor and a brick wall splitting the room in two.
	world.create_and_add_body(physics_box_shape_create(vector(10, 10, 0.25), 0.05, physics_material_get("concrete")), vector(0, 0, -0.25), IDENTITY_QUATERNION, PHYSICS_BODY_STATIC, PHYSICS_LAYER_NON_MOVING);
	world.create_and_add_body(physics_box_shape_create(vector(0.1, 10, 2), 0.05, physics_material_get("brick")), vector(0, 0, 2), IDENTITY_QUATERNION, PHYSICS_BODY_STATIC, PHYSICS_LAYER_NON_MOVING);
	sound_environment env;
	env.set_raycaster(world);
	sound_default_engine.set_listener_position(0, -3, 0, 1.5);
	mixer@ source = env.new_mixer();
	source.set_position_3d(3, 0, 1.5); // On the other side of the wall.
	sound@ s = sound();
	s.load("music.ogg");
	s.set_mixer(source);
	s.play_looped();
	sound_environment_source@ info = env.get_source(source);
	while (!key_pressed(KEY_ESCAPE)) {
		wait(5);
		env.update();
		if (key_pressed(KEY_SPACE)) screen_reader_speak("Occlusion: " + info.occlusion, true);
	}
}
```
