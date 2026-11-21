# get_size
Get the size of the window's client area, the part inside its borders.

`bool game_window::get_size(int&out w, int&out h) const;`

## Arguments:
* int&out w: receives the width.
* int&out h: receives the height.

## Returns:
bool: true on success, false otherwise.

## Remarks:
The global get_window_width() and get_window_height() functions return the size of the main window.
