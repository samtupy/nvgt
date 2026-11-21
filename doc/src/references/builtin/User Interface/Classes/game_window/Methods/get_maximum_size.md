# get_maximum_size
Get the largest size the window can be resized to.

`bool game_window::get_maximum_size(int&out w, int&out h) const;`

## Arguments:
* int&out w: receives the maximum width, or 0 for no limit.
* int&out h: receives the maximum height, or 0 for no limit.

## Returns:
bool: true on success, false otherwise.
