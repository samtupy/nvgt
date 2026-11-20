# set_sound_3d_attenuator_enabled
Enable or disable an attenuator, which decides whether mixers may use it.

`void set_sound_3d_attenuator_enabled(int attenuator_id, bool enabled);`

## Arguments:
* int attenuator_id: the attenuator, a value of the audio_attenuator enum or one provided by a plugin.
* bool enabled: whether mixers may use it.

## Remarks:
Mixers that are using an attenuator when it is disabled switch to the first attenuator that is still enabled, and switch back if it is enabled again. The built in attenuators are enabled to begin with.
