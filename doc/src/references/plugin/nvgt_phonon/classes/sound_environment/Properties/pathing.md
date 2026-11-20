# pathing
Whether sound is heard travelling around obstacles between the probes of the environment.

`bool pathing;`

## Remarks:
The default is false. Pathing needs paths to be baked, see `bake()`, and then lets a sound that is occluded by a wall still be heard coming from where it actually reaches the listener, such as through a doorway. It is heard in proportion to how occluded the direct sound is, and uses each source's `apply_occlusion` and `apply_pathing` properties.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
