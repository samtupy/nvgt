# get_3d_panner
Get the id of the panner that the mixer is currently using.

`int mixer::get_3d_panner() const;`

## Returns:
int: the id of the panner, a value of the audio_panner enum or one provided by a plugin, or -1 if none has been chosen, which is the case until the mixer is first positioned or given a panner.
