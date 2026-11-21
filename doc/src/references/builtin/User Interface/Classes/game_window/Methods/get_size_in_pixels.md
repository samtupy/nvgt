# get_size_in_pixels
Get the size of the window's client area in pixels, which on high resolution displays can be larger than its size in screen coordinates.

`bool game_window::get_size_in_pixels(int&out w, int&out h) const;`

## Arguments:
* int&out w: receives the width in pixels.
* int&out h: receives the height in pixels.

## Returns:
bool: true on success, false otherwise.
