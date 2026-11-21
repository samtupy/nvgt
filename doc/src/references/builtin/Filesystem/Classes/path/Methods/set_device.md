# set_device
Set the device of the path, such as a Windows drive letter.

`spec::path& path::set_device(const string&in device);`

## Arguments:
* const string&in device: the device to set, such as `C`. A non-empty device makes the path absolute.

## Returns:
spec::path&: this path, so calls can be chained.

## Remarks:
The current device can be read with the device property.
