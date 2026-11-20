# tail_length
Roughly how long in seconds the reverb keeps sounding after its input goes silent.

`const float audio_fdn_reverb_node::tail_length;`

## Remarks:
This follows from the other properties, mostly `t60`, and can be used to decide how long to keep a node that is about to be removed playing so its reverb isn't cut off.
