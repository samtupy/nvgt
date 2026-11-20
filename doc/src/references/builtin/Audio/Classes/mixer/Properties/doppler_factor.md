# doppler_factor
How strongly the mixer's pitch changes with its speed towards or away from the listener.

`float mixer::doppler_factor;`

## Remarks:
The default is 1. The doppler effect is the rise in pitch of something approaching and the fall as it moves away, like a passing car, and needs the velocities of the mixer and the listener to be set with `set_velocity()` and `audio_engine::set_listener_velocity()`. Set it to 0 to turn the effect off, or higher than 1 to exaggerate it.
