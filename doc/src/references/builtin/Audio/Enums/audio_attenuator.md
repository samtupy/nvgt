# audio_attenuator
This is a list of the built-in attenuators, which control how a positioned sound gets quieter with distance. These values are used with `sound_default_3d_attenuator` and `set_sound_default_3d_attenuator()`.

* audio_attenuator_basic: NVGT's basic distance attenuation.
* audio_attenuator_hrtf: NVGT's basic distance attenuation followed by air absorption, which dulls distant sounds so they sound far away rather than only quiet. This pairs with `audio_panner_hrtf`.

The nvgt_phonon plugin additionally provides `audio_attenuator_phonon`, which is Steam Audio's version of the same thing.
