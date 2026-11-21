# set_mouse_relative_mode
Set whether the mouse is hidden and reports only how far it moves, rather than its position, which suits mouse look in first person games.

`bool game_window::set_mouse_relative_mode(bool enabled);`

## Arguments:
* bool enabled: whether to enable relative mouse mode.

## Returns:
bool: true on success, false otherwise.

## Remarks:
The global mouse_relative_mode property does this for the main window.
