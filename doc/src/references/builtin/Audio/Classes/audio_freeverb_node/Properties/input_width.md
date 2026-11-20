# input_width
The stereo width of the input before it is reverberated, 0 or greater.

`float audio_freeverb_node::input_width;`

## Remarks:
The default is 0, which sends the input to the reverb in mono, so the reverb doesn't depend on where a sound is panned. 1 sends it unchanged, and higher values widen it.
