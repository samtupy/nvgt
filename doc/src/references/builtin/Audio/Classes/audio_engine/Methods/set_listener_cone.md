# set_listener_cone
Make a listener hear sounds differently depending on where they come from, as if it had a cone of attention.

`void audio_engine::set_listener_cone(int index, float inner_radians, float outer_radians, float outer_gain);`

## Arguments:
* int index: the number of the listener, starting at 0. Engines have one listener by default.
* float inner_radians: the angle in radians of the cone in which sounds are heard at full volume.
* float outer_radians: the angle in radians of the cone beyond which sounds are heard at the outer gain, with a smooth change between the two.
* float outer_gain: the volume multiplier of sounds outside the outer cone, from 0 to 1.
