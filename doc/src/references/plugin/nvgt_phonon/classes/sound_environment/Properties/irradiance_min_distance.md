# irradiance_min_distance
The smallest distance in meters at which a reflection is considered to be arriving from a surface, which limits how loud reflections from surfaces very close to the listener can become.

`float irradiance_min_distance;`

## Remarks:
The default is 0.25 and the minimum is 0.01. Raise it if you hear harsh or overly loud reflections when standing close to a wall. This takes effect at the next reflection simulation, and baked reverb is only valid for the value it was baked with.
