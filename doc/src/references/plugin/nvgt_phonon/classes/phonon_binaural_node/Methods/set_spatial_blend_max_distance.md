# set_spatial_blend_max_distance
Set the distance at which the node's sound becomes fully positioned.

`void phonon_binaural_node::set_spatial_blend_max_distance(float max_distance);`

## Arguments:
* float max_distance: the distance, in the same units passed to `set_direction()`, at which positioning is complete. The default is 4. If 0 or less, the sound is always fully positioned.
