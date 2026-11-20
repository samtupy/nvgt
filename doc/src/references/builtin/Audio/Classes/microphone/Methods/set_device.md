# set_device
Switch to recording from another input device.

`bool microphone::set_device(int device);`

## Arguments:
* int device: the index of the device in `sound_input_devices`, or -1 for the system's default.

## Returns:
bool: true if the device could be opened and started.
