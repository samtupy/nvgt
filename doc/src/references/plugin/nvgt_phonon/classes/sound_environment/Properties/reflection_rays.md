# reflection_rays
The number of rays traced from each reflection group per reflection simulation.

`int reflection_rays;`

## Remarks:
The default is 2048 and values are clamped between 1 and 65536. More rays give smoother, more accurate reflections at the cost of simulation time. Because Steam Audio averages the results of consecutive simulations, a modest number of rays works well.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
