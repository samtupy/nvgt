# occlusion_radius
The radius in meters of the sphere that this sound is treated as coming from when its occlusion type is volumetric.

`float occlusion_radius;`

## Remarks:
The default is 1 and the minimum is 0. A larger radius means the sound is partially heard as it moves past the edge of an obstacle over a larger distance. This is ignored for raycast occlusion.
