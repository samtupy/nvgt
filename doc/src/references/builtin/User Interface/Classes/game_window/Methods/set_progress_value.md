# set_progress_value
Set how full the progress indicator on the window's taskbar button is.

`bool game_window::set_progress_value(float value);`

## Arguments:
* float value: the progress, from 0.0 to 1.0.

## Returns:
bool: true on success, false if the operating system has no such indicator.

## Remarks:
This is only shown while the progress state is PROGRESS_STATE_NORMAL, PROGRESS_STATE_PAUSED or PROGRESS_STATE_ERROR.
