# audio_attenuator_phonon
A value for the audio_attenuator enum's place that selects Steam Audio's attenuator, which makes sounds quieter with distance and dulls them with air absorption.

`const int audio_attenuator_phonon;`

## Remarks:
Though it's internally registered as a standard integer, this is in all practicality an extension of the `audio_attenuator` enum. It can be used anywhere an audio_attenuator is accepted, such as `set_sound_default_3d_attenuator()` and `sound::set_3d_attenuator()`.

The volume follows NVGT's usual distance curve, so a sound's min_distance, max_distance and rolloff behave as they do with `audio_attenuator_basic`. On top of this, Steam Audio's air absorption muffles high frequencies with distance, taking one unit of distance to be about 0.3 meters by default. NVGT's built in `audio_attenuator_hrtf` does something very similar.
