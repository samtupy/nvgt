# set_3d_attenuator
Choose the attenuator that lowers the mixer's volume with distance when it is positioned in 3d.

`void mixer::set_3d_attenuator(int attenuator_id);`

## Arguments:
* int attenuator_id: a value of the audio_attenuator enum, or the id of an attenuator provided by a plugin.

## Remarks:
The attenuator decides how `rolloff`, `min_distance` and `max_distance` are applied, and the built in ones share the same distance curve so that a mixer is about as loud at a distance whichever is used. See also `hrtf`.
