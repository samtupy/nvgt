# window_progress_state
The states of the progress indicator on a window's taskbar button, set with game_window::set_progress_state().

* PROGRESS_STATE_INVALID: returned when the state can't be determined.
* PROGRESS_STATE_NONE: no progress indicator is shown.
* PROGRESS_STATE_INDETERMINATE: an indicator is shown that something is happening without saying how far along it is.
* PROGRESS_STATE_NORMAL: the progress value is shown normally.
* PROGRESS_STATE_PAUSED: the progress value is shown as paused.
* PROGRESS_STATE_ERROR: the progress value is shown as having failed.
