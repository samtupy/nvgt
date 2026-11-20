# set_direction
Set the direction that the mixer faces, which its cone is pointed in.

`void mixer::set_direction(float x, float y, float z);`

`void mixer::set_direction(const vector&in direction);`

## Arguments:
* float x, float y, float z (1): the direction.
* const vector&in direction (2): the direction.

## Remarks:
This only matters once a cone has been set with `set_cone()`, as a mixer is otherwise heard the same way in every direction.
