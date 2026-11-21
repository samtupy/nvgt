# present
Show what has been drawn on the screen.

`bool game_window::present();`

## Returns:
bool: true on success, false if the window has no renderer.

## Remarks:
The main window is presented automatically when wait() or refresh_window() is called and something was drawn, so this is only needed for additional windows.
