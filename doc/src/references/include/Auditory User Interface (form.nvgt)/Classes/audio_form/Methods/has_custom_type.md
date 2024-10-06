# has_custom_type
Determines whether the control has its custom type set.

`bool audio_form::has_custom_type(int control_index);`

## Arguments:
* int control_index: the control you want to check.

## Returns:
bool: true if the control has its custom type set, false otherwise.

## Remarks:
Please note that this method is equivalent to `audio_form::get_custom_type(control_index).empty()`
