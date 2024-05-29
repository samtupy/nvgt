# delete_list_selections
Unselect any currently selected items in a list control.

`bool audio_form::delete_list_selections(int control_index, bool reset_cursor = true, bool speak_deletion_status = true);`

## Arguments:
* int control_index: the index of the list to unselect items in.
* bool reset_cursor = true: should the user's cursor position be reset to the top of the list upon success?
* bool speak_deletion_status = true: should the user be informed of the unselection via speech feedback?

## Returns:
bool: true if the selection was successfully cleared, false otherwise.
