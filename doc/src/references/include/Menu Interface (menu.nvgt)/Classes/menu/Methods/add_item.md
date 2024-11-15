# add_item
Add an item to the menu.

`bool menu::add_item(string text, string id = "", int position = -1);`

## Arguments:
* string text: the text of the item to add to the menu.
* string id = "": the ID of the item.
* int position = -1: the position to insert the new item at (-1 = end of menu).

## Returns:
int: the  position of the new item in the menu.
