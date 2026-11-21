# set_title
Set the title of the window.

`bool game_window::set_title(const string&in title);`

## Arguments:
* const string&in title: the new title.

## Returns:
bool: true on success, false otherwise.

## Remarks:
Screen readers speak the title when the window gains focus, which makes it a good place to say what the game is doing.
