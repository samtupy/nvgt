# reflections_level
The volume multiplier of all reflections in the environment.

`float reflections_level;`

## Remarks:
The default is 0.5 and the minimum is 0. Simulated reflections are quite loud when taken at face value, so the default is toned down. This is multiplied by each source's own `reflections_level`, and 0 effectively turns reflections off.
