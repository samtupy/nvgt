# set_3d_panner
Choose the panner that places the mixer between the speakers when it is positioned in 3d.

`void mixer::set_3d_panner(int panner_id);`

## Arguments:
* int panner_id: a value of the audio_panner enum, or the id of a panner provided by a plugin, such as audio_panner_phonon_hrtf.

## Remarks:
If the panner can't be used, such as when it doesn't support the engine's number of channels, the mixer falls back to another one, and `get_3d_panner()` returns the panner actually in use while `get_preferred_3d_panner()` returns the one asked for. See also `hrtf`.
