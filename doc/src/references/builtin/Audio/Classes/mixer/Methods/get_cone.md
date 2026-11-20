# get_cone
Get the cone of the mixer.

`void mixer::get_cone(float&out inner_radians, float&out outer_radians, float&out outer_gain);`

## Arguments:
* float&out inner_radians: set to the angle within which the mixer is at full volume.
* float&out outer_radians: set to the angle beyond which it is at the outer gain.
* float&out outer_gain: set to the volume outside the outer angle.

## Remarks:
See `set_cone()`.
