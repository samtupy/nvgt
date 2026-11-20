# dry
The volume at which the input is passed through unchanged, alongside the reverb, between 0 and 1.

`float audio_freeverb_node::dry;`

## Remarks:
The default is 0, which is right for a node given to a reverb3d, as the sounds sent to it are heard directly as well. Set it to around 0.5 when a sound goes through the reverb alone and should still be heard directly.
