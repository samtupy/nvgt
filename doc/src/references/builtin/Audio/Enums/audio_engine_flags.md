# audio_engine_flags
This is a list of the flags that can be combined and passed to the first argument of the `audio_engine` constructor to change how the engine behaves.

* AUDIO_ENGINE_DURATIONS_IN_FRAMES: durations passed to the engine's objects, such as the length of a fade, are in PCM frames instead of the usual milliseconds.
* AUDIO_ENGINE_NO_AUTO_START: the engine doesn't start playing as soon as it is created, and `audio_engine::start()` has to be called.
* AUDIO_ENGINE_NO_DEVICE: the engine has no audio device and doesn't play anything. Audio is retrieved from it with `audio_engine::read()` instead.
* AUDIO_ENGINE_NO_CLIP: sample values louder than the maximum are not clipped to it.
* AUDIO_ENGINE_PERCENTAGE_ATTRIBUTES: the attributes of sounds are in percentages such as 100 rather than decimals such as 1.0, and the volume of sounds is in decibels. This is what the default engine uses for compatibility with older versions of NVGT.

Combine flags with the bitwise or operator, for example `AUDIO_ENGINE_NO_DEVICE | AUDIO_ENGINE_NO_CLIP`.
