# sound_environment_source
A sound_environment_source holds the settings and simulation results that a sound_environment keeps for one attached sound or mixer. It is created by the environment when a sound or mixer is attached, and cannot be created directly. Retrieve one with `sound_environment::get_source()`.

The settings (the properties beginning with `apply_` and the occlusion and transmission settings) can be changed at any time and are used by the next simulation. The remaining read only properties show the results of the most recent simulation run, which is useful for debugging or for driving gameplay, for example making an enemy notice a sound that isn't blocked by walls.

A source stays valid for as long as you hold a handle to it, but once its sound or mixer is detached or destroyed it no longer updates.
