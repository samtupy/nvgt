# has_baked_reverb
Whether reverb has been baked at the environment's probes.

`const bool has_baked_reverb;`

## Remarks:
This becomes true after a successful call to `bake()` or `load_baked_data()` that had reverb data, and false again when the probes change.
