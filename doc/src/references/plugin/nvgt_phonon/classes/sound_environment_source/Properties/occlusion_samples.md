# occlusion_samples
The number of points on the sound's sphere that are tested when its occlusion type is volumetric.

`int occlusion_samples;`

## Remarks:
The default is 16 and values are clamped between 1 and 16, the most that the environment's simulator supports. More samples give smoother changes in occlusion but cost more simulation time. This is ignored for raycast occlusion.
