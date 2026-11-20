# get_preferred_3d_attenuator
Get the id of the attenuator that was chosen for the mixer, which may not be the one in use if it couldn't be used.

`int mixer::get_preferred_3d_attenuator() const;`

## Returns:
int: the id of the chosen attenuator, or -1 if none has been chosen.
