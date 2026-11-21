# flags
The current state of the window as SDL window flags, which include the values of the window_flags enum.

`const uint64 game_window::flags;`

## Remarks:
For example, `(window.flags & WINDOW_FLAG_FULLSCREEN) != 0` tells whether the window is fullscreen.
