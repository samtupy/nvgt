# get_minimum_size
Get the smallest size the window can be resized to.

`bool game_window::get_minimum_size(int&out w, int&out h) const;`

## Arguments:
* int&out w: receives the minimum width, or 0 for no limit.
* int&out h: receives the minimum height, or 0 for no limit.

## Returns:
bool: true on success, false otherwise.
