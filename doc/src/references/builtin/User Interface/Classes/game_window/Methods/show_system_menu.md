# show_system_menu
Show the window's system menu, the one with commands such as move and close, at a position in the window.

`bool game_window::show_system_menu(int x, int y);`

## Arguments:
* int x: the horizontal position of the menu relative to the window.
* int y: the vertical position of the menu relative to the window.

## Returns:
bool: true on success, false if the operating system has no such menu.
