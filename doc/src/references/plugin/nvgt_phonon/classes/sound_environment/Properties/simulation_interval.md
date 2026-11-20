# simulation_interval
The minimum time in seconds between the starts of two reflection simulations.

`float simulation_interval;`

## Remarks:
The default is 0.1 and the minimum is 0. A reflection simulation only starts when the previous one has finished, so the real interval is the greater of this value and `reflection_simulation_time`. Lower values make reflections follow movement more closely but use more processor time.
