# set_output_bus_volume
Set the volume of an output bus.

`bool audio_node::set_output_bus_volume(uint bus, float volume);`

## Arguments:
* uint bus: the number of the bus, starting at 0.
* float volume: a linear multiplier applied to the audio leaving this bus, where 1 is unchanged.

## Returns:
bool: true if the volume was set.

## Remarks:
This is a cheap way to fade the audio going to one particular destination without affecting the other buses of the node.
