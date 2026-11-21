# insert_submenu
Add an item that opens a submenu.

`system_tray_menu_item@ system_tray_menu::insert_submenu(const string&in label, bool disabled = false, int pos = -1);`

## Arguments:
* const string&in label: the text of the item.
* bool disabled = false: whether the item is shown but can't be opened.
* int pos = -1: where to insert the item, counting from 0, or -1 to add it at the end.

## Returns:
system_tray_menu_item@: the new item, or null if it couldn't be added. Its submenu property is the submenu to add items to.
