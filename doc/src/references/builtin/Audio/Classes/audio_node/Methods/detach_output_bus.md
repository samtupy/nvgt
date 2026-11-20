# detach_output_bus
Disconnect an output bus from whatever it is attached to.

`bool audio_node::detach_output_bus(uint bus);`

## Arguments:
* uint bus: the number of the bus, starting at 0.

## Returns:
bool: true if the bus was detached.

## Remarks:
Audio from a node with a detached output goes nowhere and is not heard.
