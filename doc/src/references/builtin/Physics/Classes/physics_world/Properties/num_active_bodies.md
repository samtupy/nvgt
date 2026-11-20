# num_active_bodies
The number of dynamic and kinematic bodies that are awake.

`const uint physics_world::num_active_bodies;`

## Remarks:
Bodies that stop moving fall asleep, and stay that way until they are touched or `activate_body()` is called, and they cost almost nothing to simulate while they do. A low number compared to `num_bodies` means the world is settled.
