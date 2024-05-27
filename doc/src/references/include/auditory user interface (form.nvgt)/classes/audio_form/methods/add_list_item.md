# add_list_item
Add a string item to a list control.

1. `bool audio_form::add_list_item(int control_index, string option, int position = -1, bool selected = false, bool focus_if_first = true);`
2. `bool audio_form::add_list_item(int control_index, string option, string id, int position = -1, bool selected = false, bool focus_if_first = true);`

## Arguments (1):
* int control_index: the control index of the list to add to.
* string option: the item to add to the list.
* int position = -1: the position to insert the new item at (-1 = end of list).
* bool selected = false: should this item be selected by default?
* bool focus_if_first = true: if this item is the first in the list and no other item gets explicitly focused, this item will be focused.

## Arguments (2):
* int control_index: the control index of the list to add to.
* string option: the item to add to the list.
* string id: the ID of the item in the list.
* int position = -1: the position to insert the new item at (-1 = end of list).
* bool selected = false: should this item be selected by default?
* bool focus_if_first = true: if this item is the first in the list and no other item gets explicitly focused, this item will be focused.

## Returns:
bool: true if the item was successfully added, false otherwise.

## Remarks:
This function only works on list controls.
