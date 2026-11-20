# add_probe
Add a single probe at a position.

`void sound_environment::add_probe(const vector&in position, float radius = 2);`

## Arguments:
* const vector&in position: the center of the probe.
* float radius = 2: the influence radius of the probe in meters, within which the listener is considered to be at the probe.

## Remarks:
Any baked data is discarded.
