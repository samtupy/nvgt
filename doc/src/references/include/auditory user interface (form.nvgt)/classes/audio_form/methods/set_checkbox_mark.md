# set_checkbox_mark
Set the state of a checkbox (either checked or unchecked).

`bool audio_form::set_checkbox_mark(int control_index, bool checked);`

## Arguments:
* int control_index: the control index of the checkbox.
* bool checked: whether the checkbox should be set to checked or not.

## Returns:
bool: true if the operation was successful, false otherwise. To get error information, look at `audio_form::get_last_error();`.
