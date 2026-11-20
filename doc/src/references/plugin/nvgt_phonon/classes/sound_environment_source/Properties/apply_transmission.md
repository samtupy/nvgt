# apply_transmission
Whether sound that passes through obstacles is heard.

`bool apply_transmission;`

## Remarks:
The default is true. When an obstacle occludes the sound, transmission decides how much gets through the material of the obstacle, separately in the low, mid and high frequency bands. When false, an occluded sound is fully silent unless it is heard through pathing. This has no effect if `apply_occlusion` is false.
