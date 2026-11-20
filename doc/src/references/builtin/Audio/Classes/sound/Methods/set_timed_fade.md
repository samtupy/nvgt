# set_timed_fade
Schedule a fade of the sound's volume to start at a time on the engine's clock.

`void sound::set_timed_fade(float start_volume, float end_volume, uint64 length, uint64 absolute_time);`

## Arguments:
* float start_volume: the volume to start the fade from, as a linear gain where 1 is full volume, or a negative number to start from the current volume.
* float end_volume: the volume to end at, as a linear gain.
* uint64 length: how long the fade takes, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.
* uint64 absolute_time: when the fade starts on the engine's clock, see `audio_engine::time_in_milliseconds`, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.

## Remarks:
Unlike `set_fade()`, the volumes here are always linear gains, even in the default engine. This lets fades be lined up precisely with music or with other scheduled sounds.
