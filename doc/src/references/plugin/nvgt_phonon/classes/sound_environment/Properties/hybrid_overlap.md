# hybrid_overlap
For hybrid reflections, how much the convolved and parametric parts overlap around the transition, as a fraction between 0 and 1.

`float hybrid_overlap;`

## Remarks:
The default is 0.25 and values are clamped between 0 and 1. This is only used when `reflection_type` is `SOUND_ENVIRONMENT_REFLECTIONS_HYBRID`.
