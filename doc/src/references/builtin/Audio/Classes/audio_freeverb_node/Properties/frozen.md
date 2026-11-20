# frozen
Whether the reverb holds its current tail forever and ignores new input.

`bool audio_freeverb_node::frozen;`

## Remarks:
This can be used for effects such as a sound that hangs in the air, or a drone made from a moment of audio. Setting it back to false lets the tail decay as normal.
