# max_sources
The number of reflection groups, which is the maximum number of separate places reflections are simulated for at once.

`int max_sources;`

## Remarks:
The default is 16 and values are clamped between 0 and 1024. Rather than simulating and convolving reflections for every sound, the environment keeps this many groups, and each attached sound adds its signal to the group nearest to it, hearing the reflections simulated at that position. A sound that cannot get a group of its own shares the nearest group it can, or otherwise hears the listener's reverb. Setting this to 0 leaves only the listener's reverb.

The cost of reflections is proportional to this number rather than to the number of sounds, so it is the main control over performance. See also `reflection_group_size`.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
