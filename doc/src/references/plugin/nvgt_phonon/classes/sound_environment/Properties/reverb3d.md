# reverb3d
The reverb3d object that routes sounds through this environment.

`const reverb3d@+ reverb3d;`

## Remarks:
Every sound and mixer attached to the environment is attached to this reverb3d, and its output mixer is the one returned by `output_mixer`. You rarely need to touch it directly, `attach()` and `detach()` are the intended way to move sounds in and out of the environment if `sound_environment::new_sound` is not enough.
