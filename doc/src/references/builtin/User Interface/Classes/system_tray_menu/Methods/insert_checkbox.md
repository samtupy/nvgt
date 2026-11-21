# insert_checkbox
Add an item that can be checked or unchecked.

`system_tray_menu_item@ system_tray_menu::insert_checkbox(const string&in label, bool checked = false, system_tray_callback@ callback = null, bool disabled = false, int pos = -1);`

## Arguments:
* const string&in label: the text of the item.
* bool checked = false: whether the item starts checked.
* system_tray_callback@ callback = null: the function to call when the item is chosen, which takes the item as its parameter.
* bool disabled = false: whether the item is shown but can't be chosen.
* int pos = -1: where to insert the item, counting from 0, or -1 to add it at the end.

## Returns:
system_tray_menu_item@: the new item, or null if it couldn't be added.

## Remarks:
Choosing the item toggles it before its callback is called, so the callback can read the item's checked property to find out its new state.
