# get_3d_attenuator
Get the id of the attenuator that the mixer is currently using.

`int mixer::get_3d_attenuator() const;`

## Returns:
int: the id of the attenuator, a value of the audio_attenuator enum or one provided by a plugin, or -1 if none has been chosen, which is the case until the mixer is first positioned or given an attenuator.
