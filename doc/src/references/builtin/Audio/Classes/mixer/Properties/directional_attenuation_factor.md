# directional_attenuation_factor
How strongly the mixer is panned according to its direction from the listener.

`float mixer::directional_attenuation_factor;`

## Remarks:
The default is 1. At 0 a positioned mixer is not panned at all and only gets quieter with distance, and values above 1 pan it more sharply, so that something only slightly to one side is heard further to that side.
