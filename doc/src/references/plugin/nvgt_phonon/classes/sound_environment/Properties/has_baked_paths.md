# has_baked_paths
Whether the paths sound can take between the environment's probes have been baked.

`const bool has_baked_paths;`

## Remarks:
This becomes true after a successful call to `bake()` or `load_baked_data()` that had path data, and false again when the probes change. Paths are only used when the `pathing` property is enabled.
