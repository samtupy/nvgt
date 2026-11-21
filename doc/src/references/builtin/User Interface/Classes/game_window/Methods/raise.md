# raise
Bring the window in front of other windows and give it the keyboard focus.

`bool game_window::raise();`

## Returns:
bool: true on success, false otherwise.

## Remarks:
Operating systems may refuse to take the focus from another program, and flash the window's taskbar button instead.
