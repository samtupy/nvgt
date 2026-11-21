# set_surface_vsync
Set the vertical sync of the window's software surface.

`bool game_window::set_surface_vsync(int vsync);`

## Arguments:
* int vsync: 0 to disable vertical sync, 1 to synchronize with every refresh of the display, 2 with every second refresh and so on, or -1 for adaptive sync.

## Returns:
bool: true on success, false otherwise.
