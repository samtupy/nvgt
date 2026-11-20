# use_listener_reverb
Whether sounds that have no reflection group of their own hear reflections simulated at the listener's position.

`bool use_listener_reverb;`

## Remarks:
The default is true. This is what lets a brand new sound, such as a footstep, reverberate immediately before its own group has been simulated, and also what sounds hear when every group is taken. The reverb is attenuated by the sound's distance from the listener. When false, such sounds have no reflections.
