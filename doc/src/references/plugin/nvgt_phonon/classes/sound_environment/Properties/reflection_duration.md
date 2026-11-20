# reflection_duration
The length in seconds of the reverb tail that is simulated, and thus the longest reverb the environment can produce.

`float reflection_duration;`

## Remarks:
The default is 1 and values are clamped between 0.1 and 10. Convolution cost grows with this value, and `reflection_bounces` must be high enough to fill it.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
