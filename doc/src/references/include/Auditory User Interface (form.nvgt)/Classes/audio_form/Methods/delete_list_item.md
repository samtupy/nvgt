# delete_list_item
Remove an item from a list control.

`bool audio_form::delete_list_item(int control_index, int list_index, bool reset_cursor = true, bool speak_deletion_status = true);`

## Arguments:
* int control_index: the index of the list to remove the item from.
* int list_index: the index of the item to remove.
* bool reset_cursor = true: should the user's cursor position be reset to the top of the list upon success?
* bool speak_deletion_status = true: should the user be informed of the deletion via speech feedback?

## Returns:
bool: true if the item was successfully deleted, false otherwise.
