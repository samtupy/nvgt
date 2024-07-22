# get_list_selections
Get a list of all items currently selected in a list control.

`int[]@ audio_form::get_list_selections(int control_index);`

## Arguments:
* int control_index: the index of the list to query.

## Returns:
int[]@: handle to an array containing the index of every selected item in the list (see remarks).

## Remarks:
In the context of this function, a selected item is any item that  is checked (if the list supports multiselection), as well as the currently selected item. If you want to only get the state of checked list items, see the `get_checked_list_items()` function.
