# set_fade
Fade the volume of the mixer from one level to another over time.

`void mixer::set_fade(float start_volume, float end_volume, uint64 length);`

## Arguments:
* float start_volume: the volume to start the fade from. Pass FLOAT_MAX to start from the current volume of the fade.
* float end_volume: the volume to end at.
* uint64 length: how long the fade takes, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.

## Remarks:
The fade is applied on top of `volume`, so it doesn't change that property, and its current level can be read with `current_fade_volume`. The volume stays at `end_volume` after the fade ends. In the default engine this is in the units described in the remarks of the mixer class. Fading a mixer to silence is a smooth way to quiet a whole group of sounds, such as when leaving an area.
