# set_stop_time_with_fade
Schedule the sound to fade out and stop at a time on the engine's clock.

`void sound::set_stop_time_with_fade(uint64 absolute_time, uint64 fade_length);`

## Arguments:
* uint64 absolute_time: when the sound should have stopped, on the engine's clock, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.
* uint64 fade_length: how long the fade out before that takes, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.

## Remarks:
See also `mixer::set_stop_time()`, which stops without a fade.
