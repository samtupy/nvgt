# set_sound_3d_panner_enabled
Enable or disable a panner, which decides whether mixers may use it.

`void set_sound_3d_panner_enabled(int panner_id, bool enabled);`

## Arguments:
* int panner_id: the panner, a value of the audio_panner enum or one provided by a plugin.
* bool enabled: whether mixers may use it.

## Remarks:
Mixers that are using a panner when it is disabled switch to the first panner that is still enabled, and switch back if it is enabled again. This can be used to stop all sounds using an expensive panner, such as an HRTF, at once. The built in panners are enabled to begin with.
