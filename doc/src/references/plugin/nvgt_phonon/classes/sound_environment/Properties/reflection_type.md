# reflection_type
The kind of reflection effect the environment uses.

`sound_environment_reflection_type reflection_type;`

## Remarks:
The default is `SOUND_ENVIRONMENT_REFLECTIONS_HYBRID`. See the `sound_environment_reflection_type` enum for what each type does.

Parametric and hybrid reflections cannot use Steam Audio's reflection mixer, so for them `use_reflection_mixer` has no effect.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
