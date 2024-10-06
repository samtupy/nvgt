# set_slider
Sets the value of the slider control.

`bool audio_form::set_slider(int control_index, double value, double min = -1, double max = -1);`

## Arguments:
* int control_index: the index of the control.
* double value: the value to set.
* double min = -1: the minimum value to set. This can be omitted.
* double max = -1: the maximum value to set. This can be omitted.

## Returns:
bool: true on success, false on failure.

## Remarks:
This method only works on slider control.
