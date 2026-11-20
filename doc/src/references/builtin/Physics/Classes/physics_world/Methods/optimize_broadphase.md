# optimize_broadphase
Rebuild the structure the world uses to find nearby bodies so that it is as quick as possible.

`void physics_world::optimize_broadphase();`

## Remarks:
Call this once after adding a large number of bodies at the start of a level, for example every piece of static scenery, and before the first call to `update()`. There is no need to call it while the game runs.
