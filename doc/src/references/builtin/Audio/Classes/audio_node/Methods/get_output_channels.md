# get_output_channels
Get the number of channels that an output bus carries.

`uint audio_node::get_output_channels(uint bus) const;`

## Arguments:
* uint bus: the number of the bus, starting at 0.

## Returns:
uint: the number of channels, for example 2 for stereo, or 0 if the bus does not exist.
