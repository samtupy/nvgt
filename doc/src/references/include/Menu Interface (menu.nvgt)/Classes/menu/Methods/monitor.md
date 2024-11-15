# monitor
Monitors the menu; handles keyboard input, the callback, sounds and more. Should be called in a loop as long as the menu is active.

`bool menu::monitor();`

## Returns:
bool: true if the menu should keep running, or false if it has been exited or if an option has been selected.
