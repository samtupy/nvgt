# get_checked_list_items
Get a list of all currently checked items in a list control.

`int[]@ audio_form::get_checked_list_items(int control_index);`

## Arguments:
* int control_index: the index of the list to query.

## Returns:
int[]@: handle to an array containing the index of every checked item in the list.

## Remarks:
This function only works on multiselect lists. If you want something that also works on single-select lists, see `get_list_selections()`.
