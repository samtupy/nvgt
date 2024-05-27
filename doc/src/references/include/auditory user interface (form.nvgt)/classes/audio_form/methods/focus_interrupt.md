# focus_interrupt
Set a particular control to have the keyboard focus, and notify the user (cutting off any previous speech).

`bool audio_form::focus_interrupt(int control_index);`

## Arguments:
* int control_index: the index of the control to focus.

## Returns:
bool: true if the control was successfully focused, false otherwise.
