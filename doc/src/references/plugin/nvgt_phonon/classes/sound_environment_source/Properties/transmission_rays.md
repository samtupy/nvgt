# transmission_rays
The number of rays traced from the listener to this sound to find the materials that sound passes through.

`int transmission_rays;`

## Remarks:
The default is 3 and values are clamped between 1 and 64. More rays give a better result when the sound is behind several obstacles of different materials.
