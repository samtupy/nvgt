# simulation_threads
The number of threads Steam Audio uses to trace reflection rays.

`int simulation_threads;`

## Remarks:
The default is half of the machine's processor threads, and values are clamped between 1 and 64. These threads compete with the audio thread, so more is not always better.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
