# sync
Wait for any pending changes to the window's state, such as a change of size, position or fullscreen, to be applied.

`bool game_window::sync();`

## Returns:
bool: true on success, false otherwise.

## Remarks:
Some operating systems apply such changes asynchronously, so this makes the window's properties up to date immediately. It returns false if the changes didn't complete within a short time.
