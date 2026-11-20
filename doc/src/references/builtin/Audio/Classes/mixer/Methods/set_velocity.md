# set_velocity
Set how fast and in which direction the mixer is moving, for the doppler effect.

1. `void mixer::set_velocity(float x, float y, float z);`
2. `void mixer::set_velocity(const vector&in velocity);`

## Arguments:
* float x, float y, float z (1): the velocity in units per second along each axis.
* const vector&in velocity (2): the velocity.

## Remarks:
Setting a velocity doesn't move the mixer, it only changes its pitch as it moves towards or away from the listener, see `doppler_factor`. Keep it up to date along with the position.
