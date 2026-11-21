# set_progress_state
Set the state of the progress indicator shown on the window's taskbar button.

`bool game_window::set_progress_state(uint state);`

## Arguments:
* uint state: a value of the window_progress_state enum.

## Returns:
bool: true on success, false if the operating system has no such indicator.

## Remarks:
This can show the progress of a download or level load while the game is in the background. See set_progress_value().
