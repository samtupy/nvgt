# get_device
Get the output device the engine plays to.

`int audio_engine::get_device() const;`

## Returns:
int: the index of the device in the list of output devices, or -1 if it can't be determined or the engine has no device.

## Remarks:
The list of devices is in the `sound_output_devices` property.
