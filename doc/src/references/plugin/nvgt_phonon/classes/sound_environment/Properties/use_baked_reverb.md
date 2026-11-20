# use_baked_reverb
Whether the listener's reverb is looked up from baked data when the listener is within one of the environment's probes.

`bool use_baked_reverb;`

## Remarks:
The default is true. This only does anything once reverb has been baked, see `bake()`. Looking the reverb up is much cheaper than simulating it and allows for higher quality than can be afforded in real time, but it is only used for the listener's own reverb, groups elsewhere are still simulated.
