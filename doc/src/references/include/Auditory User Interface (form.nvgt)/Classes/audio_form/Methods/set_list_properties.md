# set_list_properties
Sets the properties of a list control.

`bool audio_form::set_list_propertyes(int control_index, bool multiselect=false, bool repeat_boundary_items=false);`

## Arguments:
* int control_index: the index of the list.
* bool multiselect = false: can the user select multiple items in this list?
* bool repeat_boundary_items = false: do items repeat if you press the arrow keys at the edge of the list?

## Returns:
bool: true on success, false on failure.
