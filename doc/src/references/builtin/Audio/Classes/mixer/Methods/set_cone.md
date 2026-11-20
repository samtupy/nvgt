# set_cone
Make the mixer directional, so that it is quieter when it faces away from the listener.

`void mixer::set_cone(float inner_radians, float outer_radians, float outer_gain);`

## Arguments:
* float inner_radians: the angle of the cone around the mixer's `direction` within which it is at full volume.
* float outer_radians: the angle beyond which it is at `outer_gain`. Between the two angles the volume changes smoothly.
* float outer_gain: the volume as a linear gain, where 1 is full volume, of the mixer when the listener is outside the outer angle.

## Remarks:
A cone suits things that send sound in one direction, such as a loudspeaker, a person talking or the exhaust of a car. The angles are the whole width of the cone, so an inner angle of pi is a half circle facing the mixer's direction. The default cone has both angles at a full circle, which means no cone. Point it with `set_direction()`.
