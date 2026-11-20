# set_position_3d
Place the mixer at a point in 3d space, so that it is heard from that point relative to the listener.

`void mixer::set_position_3d(float x, float y, float z);`

`void mixer::set_position_3d(const vector&in position);`

## Arguments:
* float x, float y, float z (1): the coordinates of the position.
* const vector&in position (2): the position.

## Remarks:
The first call turns on `spatialization_enabled`. Everything in the mixer is then heard from this position, panned to the direction it is in and quieter with distance according to `rolloff`, `min_distance` and `max_distance`. Call this again whenever the object the mixer belongs to moves.

Position the mixer of an object rather than each of the sounds in it, see the remarks of the mixer class. If the mixer has a `shape`, the position is the position of the shape.
