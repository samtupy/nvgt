# is_read_only
Determine if a particular control is read-only or not.

`bool audio_form::is_read_only(int control_index);`

## Arguments:
* int control_index: the index of the control to query.

## Returns:
bool: true if the control is read-only, false if it's not.

## Remarks:
This function only works on input boxes and checkboxes.
