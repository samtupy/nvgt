# set_position
Sets the sound's position in 3d space.

`bool sound::set_position(float listener_x, float listener_y, float listener_z, float sound_x, float sound_y, float sound_z, float rotation, float pan_step, float volume_step);`

## Arguments:
* float listener_x: the x position of the listener.
* float listener_y: the y position of the listener.
* float listener_z: the z position of the listener.
* float sound_x: the x position of the sound.
* float sound_y: the y position of the sound.
* float sound_z: the z position of the sound.
* float rotation: the rotation of the listener (in degrees).
* float pan_step: the pan step (e.g. how extreme the panning is).
* float volume_step: the volume step (very similar to pan_step but for volume).

## Returns:
bool: true if the position was successfully set, false otherwise.
