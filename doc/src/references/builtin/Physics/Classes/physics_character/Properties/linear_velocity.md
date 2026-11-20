# linear_velocity
How fast and in which direction the character is moving, in meters per second.

`vector physics_character::linear_velocity;`

## Remarks:
Set this to make the character walk or jump. It includes the speed of falling in the up direction, so when walking along the ground set only the components that are not up. The character is stopped by walls and kept on the floor by the simulation, so the speed it actually moves at can differ from what you set.
