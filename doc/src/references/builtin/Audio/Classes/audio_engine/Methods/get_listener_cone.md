# get_listener_cone
Get a listener's cone.

`void audio_engine::get_listener_cone(int index, float&out inner_radians, float&out outer_radians, float&out outer_gain) const;`

## Arguments:
* int index: the number of the listener, starting at 0. Engines have one listener by default.
* float&out inner_radians: receives the inner angle in radians.
* float&out outer_radians: receives the outer angle in radians.
* float&out outer_gain: receives the volume multiplier outside the outer cone.
