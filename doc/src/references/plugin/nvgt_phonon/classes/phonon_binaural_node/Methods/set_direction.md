# set_direction
Set the direction the node positions its sound in.

1. void phonon_binaural_node::set_direction(float x, float y, float z, float distance);
2. void phonon_binaural_node::set_direction(const vector&in direction, float distance);

## Arguments:
* float x: the right component of the direction (1).
* float y: the up component of the direction (1).
* float z: the backward component of the direction (1).
* const vector&in direction: the direction as a vector (2).
* float distance: how far away the sound is, which with `set_spatial_blend_max_distance()` determines how strongly it is positioned.

## Remarks:
The direction is relative to the listener's head, with x to the right, y up and z behind, as used by Steam Audio. It does not need to be normalized.

The sound is fully positioned when distance is at least the node's spatial blend max distance, and is increasingly unpositioned as distance approaches 0, so that a sound at the listener's own position isn't snapped to one direction.
