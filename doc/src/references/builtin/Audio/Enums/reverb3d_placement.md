# reverb3d_placement
This is a list of the places in a sound's spatialization that its send to a reverb3d can be taken from, used with `set_reverb3d_at()` on a sound or mixer.

* reverb3d_prepan: before the sound is panned, so the reverb receives the sound as it was before being positioned.
* reverb3d_postpan: after the sound is panned but before its volume is lowered with distance. This is the default, used when the `reverb3d` property is set, as the reverb3d sets the volume of the send from the distance itself.
* reverb3d_postattenuate: after the sound is panned and its volume is lowered with distance, so that the reverb of distant sounds is quieter still.
