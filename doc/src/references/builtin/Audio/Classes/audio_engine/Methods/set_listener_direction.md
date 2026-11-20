# set_listener_direction
Turn a listener to face a direction.

1. `void audio_engine::set_listener_direction(int index, float x, float y, float z);`
2. `void audio_engine::set_listener_direction(int index, const vector&in direction);`

## Arguments:
* int index: the number of the listener, starting at 0. Engines have one listener by default.
* float x: the x component of the direction (1).
* float y: the y component of the direction (1).
* float z: the z component of the direction (1).
* const vector&in direction: the direction (2).

## Remarks:
This is a direction to face, not a position to look at. The default is `(0, 1, 0)`, facing forward along the y axis. A sound that is to the right of this direction is heard on the right, which changes as you turn the listener with the player. The direction does not need to be normalized.

A common desire is to rotate a game player by an angle given in degrees, letting them turn in a circle. You can convert the desired direction in degrees to radians `(degrees * pi / 180)` and call `set_listener_direction(index, sin(radians), cos(radians), 0)` to position sounds in the environment according to the direction in degrees that the character is facing.
