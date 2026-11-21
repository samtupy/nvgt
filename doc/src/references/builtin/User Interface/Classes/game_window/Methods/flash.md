# flash
Flash the window's taskbar button to get the user's attention.

`bool game_window::flash(uint operation);`

## Arguments:
* uint operation: what to do, a value of the window_flash_operation enum.

## Returns:
bool: true on success, false otherwise.

## Remarks:
This is useful to let a player know something happened while they were in another program, such as a match being found.
