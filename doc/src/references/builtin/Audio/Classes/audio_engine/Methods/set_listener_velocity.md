# set_listener_velocity
Set how fast a listener is moving.

1. `void audio_engine::set_listener_velocity(int index, float x, float y, float z);`
2. `void audio_engine::set_listener_velocity(int index, const vector&in velocity);`

## Arguments:
* int index: the number of the listener, starting at 0. Engines have one listener by default.
* float x: the x component of the velocity (1).
* float y: the y component of the velocity (1).
* float z: the z component of the velocity (1).
* const vector&in velocity: the velocity (2).

## Remarks:
This is used to work out how the pitch of sounds is shifted by the Doppler effect, and is not otherwise calculated for you.
