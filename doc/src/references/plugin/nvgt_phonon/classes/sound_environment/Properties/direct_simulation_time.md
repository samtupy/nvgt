# direct_simulation_time
How long the most recent direct simulation (occlusion and transmission) took, in milliseconds.

`const float direct_simulation_time;`

## Remarks:
This simulation runs on the thread that calls `update()` every time it is called, so it is part of your frame time.
