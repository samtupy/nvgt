# find_closest_listener
Find the listener that is closest to a position.

1. `int audio_engine::find_closest_listener(float x, float y, float z) const;`
2. `int audio_engine::find_closest_listener(const vector&in position) const;`

## Arguments:
* float x: the x coordinate (1).
* float y: the y coordinate (1).
* float z: the z coordinate (1).
* const vector&in position: the position (2).

## Returns:
int: the number of the closest listener.

## Remarks:
This matters only when the engine has more than one listener, such as in split screen games.
