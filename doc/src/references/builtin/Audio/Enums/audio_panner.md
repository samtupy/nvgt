# audio_panner
This is a list of the built-in panners, which control how a positioned sound is placed between the speakers. These values are used with `sound_default_3d_panner` and `set_sound_default_3d_panner()`.

* audio_panner_basic: simple panning that only changes the volume of the left and right channels.
* audio_panner_phonon_hrtf: Steam Audio's HRTF panning, which makes sounds seem to come from a direction around the listener and works best with headphones.
