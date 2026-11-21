# set_position
Move the window.

`bool game_window::set_position(int x, int y);`

## Arguments:
* int x: the new horizontal position of the window's top left corner, in screen coordinates measured from the left edge of the desktop.
* int y: the new vertical position of the window's top left corner, in screen coordinates measured from the top edge of the desktop.

## Returns:
bool: true on success, false otherwise.

## Remarks:
Positions are in screen coordinates rather than necessarily pixels, the same units as the window's size, where 0, 0 is the top left of the primary display. On high resolution displays a screen coordinate can cover more than one pixel. A window can be placed partly or wholly off the screen, and some systems, such as most Linux desktops using Wayland, don't allow programs to choose where their windows go, in which case this returns false.
