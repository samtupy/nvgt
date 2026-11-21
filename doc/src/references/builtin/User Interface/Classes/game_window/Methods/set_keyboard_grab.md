# set_keyboard_grab
Set whether the window grabs the keyboard, receiving system shortcuts such as Alt+Tab while it has the focus.

`bool game_window::set_keyboard_grab(bool grabbed);`

## Arguments:
* bool grabbed: whether to grab the keyboard.

## Returns:
bool: true on success, false otherwise.

## Remarks:
Grabbing system shortcuts can stop screen reader users from leaving the game, so this should be used with great care.
