# audio_positioning_mode
This is a list of the ways that the position of a mixer or sound can be interpreted, used with `mixer::positioning`.

* AUDIO_POSITIONING_ABSOLUTE: the position is a point in the world, and the mixer is heard relative to wherever the listener is. This is the default.
* AUDIO_POSITIONING_RELATIVE: the position is relative to the listener's position and direction, so the mixer moves and turns with the listener, which suits sounds that follow the player such as their own footsteps.
