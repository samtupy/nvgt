# draw_menu
Draw a simple vertical menu, with each item centered on a position and the selected item highlighted.

`void game_window::draw_menu(array<string>@ items, float x, float y);`

## Arguments:
* array<string>@ items: the text of the items. The selected item starts with an asterisk, which isn't drawn.
* float x: the horizontal position the items are centered on.
* float y: the vertical position of the top of the first item.

## Remarks:
This gives sighted players something to see while a menu is spoken. Nothing is drawn if the window has no font.
