# reflection_bounces
The number of times each ray may bounce around the scene.

`int reflection_bounces;`

## Remarks:
The default is 32 and values are clamped between 1 and 64. The length of reverb that can be heard depends on this, as a ray that has reached its bounce limit stops contributing, so few bounces produce short reverb tails even if `reflection_duration` is long. This takes effect at the next reflection simulation.
