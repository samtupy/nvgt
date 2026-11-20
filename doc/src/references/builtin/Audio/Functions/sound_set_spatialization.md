# sound_set_spatialization
Choose the panner and attenuator that sounds use by default, enabling them if they aren't already.

`bool sound_set_spatialization(int panner, int attenuator, bool disable_previous = false, bool set_default = true);`

## Arguments:
* int panner: the panner to use, a value of the audio_panner enum or one provided by a plugin.
* int attenuator: the attenuator to use, a value of the audio_attenuator enum or one provided by a plugin.
* bool disable_previous = false: whether to disable the panner and attenuator that were the defaults before, so that mixers using them switch to another.
* bool set_default = true: whether to make these the defaults. If false, they are only enabled.

## Returns:
bool: true if both the panner and the attenuator exist.

## Remarks:
`set_sound_global_hrtf()` is a simpler way to switch between the built in panners and attenuators, and plugins such as nvgt_phonon may provide functions of their own for theirs. See also `set_sound_3d_panner_enabled()`.
