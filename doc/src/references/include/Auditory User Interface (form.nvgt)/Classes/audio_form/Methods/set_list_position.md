# set_list_position
Set the user's cursor in a list control.

`bool audio_form::set_list_position(int control_index, int position = -1, bool speak_new_item = false);`

## Arguments:
* int control_index: the index of the list.
* int position = -1: the new cursor position (-1 for no selection).
* bool speak_new_item = false: should the user be notified of the selection change via speech?

## Returns:
bool: true if the cursor position was successfully set, false otherwise.
