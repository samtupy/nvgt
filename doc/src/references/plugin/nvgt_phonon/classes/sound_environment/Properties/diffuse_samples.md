# diffuse_samples
The number of rays traced for each diffuse (scattered) reflection at every bounce.

`int diffuse_samples;`

## Remarks:
The default is 32 and values are clamped between 1 and 4096. Higher values give smoother diffuse reverb at the cost of simulation time.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
