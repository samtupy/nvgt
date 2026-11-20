# modulation_depth
How far in seconds the reverb's delay lines are varied over time, between 0 and 0.3.

`float audio_fdn_reverb_node::modulation_depth;`

## Remarks:
The default is 0.01. A little modulation hides the metallic ringing that reverbs made from delay lines can have, but too much makes the reverb sound like a chorus effect, with a wavering pitch.
