# get_borders_size
Get the size of the window's decorations, such as its title bar, on each side of the client area.

`bool game_window::get_borders_size(int&out top, int&out left, int&out bottom, int&out right) const;`

## Arguments:
* int&out top: receives the size of the top border, which includes the title bar.
* int&out left: receives the size of the left border.
* int&out bottom: receives the size of the bottom border.
* int&out right: receives the size of the right border.

## Returns:
bool: true on success, false if the size isn't known, as can happen just after the window is created.
