# positioning
Whether the mixer's position is in the world or relative to the listener, a value of the audio_positioning_mode enum.

`audio_positioning_mode mixer::positioning;`

## Remarks:
With the default, AUDIO_POSITIONING_ABSOLUTE, a position given to `set_position_3d()` is a point in the world. With AUDIO_POSITIONING_RELATIVE it is relative to the listener's position and direction, so that `vector(0, 1, 0)` is always 1 unit in front of the listener wherever it is and whichever way it faces, which is useful for sounds that follow the player such as their own footsteps or a radio they are carrying.
