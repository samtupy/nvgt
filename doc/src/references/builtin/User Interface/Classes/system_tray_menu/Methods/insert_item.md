# insert_item
Add an item that runs a callback when chosen.

`system_tray_menu_item@ system_tray_menu::insert_item(const string&in label, system_tray_callback@ callback = null, bool disabled = false, int pos = -1);`

## Arguments:
* const string&in label: the text of the item.
* system_tray_callback@ callback = null: the function to call when the item is chosen, which takes the item as its parameter.
* bool disabled = false: whether the item is shown but can't be chosen.
* int pos = -1: where to insert the item, counting from 0, or -1 to add it at the end.

## Returns:
system_tray_menu_item@: the new item, or null if it couldn't be added.
