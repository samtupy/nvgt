# insert_separator
Add a separator line between items.

`system_tray_menu_item@ system_tray_menu::insert_separator(int pos = -1);`

## Arguments:
* int pos = -1: where to insert the item, counting from 0, or -1 to add it at the end.

## Returns:
system_tray_menu_item@: the separator, or null if it couldn't be added.
