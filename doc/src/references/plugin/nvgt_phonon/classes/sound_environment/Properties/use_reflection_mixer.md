# use_reflection_mixer
Whether convolved reflections of all groups are combined by Steam Audio's reflection mixer before being decoded.

`bool use_reflection_mixer;`

## Remarks:
The default is true. The mixer decodes the sound field once for the whole environment rather than once per group, which is cheaper, and it is only used when `reflection_type` is `SOUND_ENVIRONMENT_REFLECTIONS_CONVOLUTION`. Parametric and hybrid reflections are summed without it whatever this is set to.
