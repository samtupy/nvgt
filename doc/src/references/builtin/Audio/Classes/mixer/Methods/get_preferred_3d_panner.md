# get_preferred_3d_panner
Get the id of the panner that was chosen for the mixer, which may not be the one in use if it couldn't be used.

`int mixer::get_preferred_3d_panner() const;`

## Returns:
int: the id of the chosen panner, or -1 if none has been chosen.
