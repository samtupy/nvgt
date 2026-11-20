# set_listener_world_up
Set which way is up for a listener.

1. `void audio_engine::set_listener_world_up(int index, float x, float y, float z);`
2. `void audio_engine::set_listener_world_up(int index, const vector&in world_up);`

## Arguments:
* int index: the number of the listener, starting at 0. Engines have one listener by default.
* float x: the x component of the up direction (1).
* float y: the y component of the up direction (1).
* float z: the z component of the up direction (1).
* const vector&in world_up: the up direction (2).

## Remarks:
The default is `(0, 0, 1)`, with z up as everywhere in NVGT. Together with the listener's direction this decides which side is left and which is right.
