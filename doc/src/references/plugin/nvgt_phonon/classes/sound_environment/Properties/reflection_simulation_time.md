# reflection_simulation_time
How long the most recent reflection simulation took, in milliseconds.

`const float reflection_simulation_time;`

## Remarks:
Compare this to `simulation_interval`. If simulations take much longer than the interval, reflections will update less often than you asked, and lowering `reflection_rays`, `max_sources` or `reflection_order` will help.
