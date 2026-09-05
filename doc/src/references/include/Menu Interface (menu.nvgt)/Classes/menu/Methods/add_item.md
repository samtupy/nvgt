# add_item
Add an item to the menu.

`int menu::add_item(const string&in text, const string&in id = "", int position = -1);`

## Arguments:
* const string&in text: the text of the item to add to the menu.
* const string&in id = "": the ID of the item.
* int position = -1: the position to insert the new item at (-1 = end of menu).

## Returns:
int: the position of the new item in the menu, or -1 if the item could not be added.
