# set_device
Change the output device the engine plays to.

`bool audio_engine::set_device(int device);`

## Arguments:
* int device: the index of the device in the list of output devices, or -1 for the system's default device.

## Returns:
bool: true if the device was changed, false if it is already in use, the index is invalid, or the engine has no device.

## Remarks:
Playing sounds continue on the new device.
