# set_aspect_ratio
Keep the window's client area within a range of aspect ratios when resized.

`bool game_window::set_aspect_ratio(float min_aspect, float max_aspect);`

## Arguments:
* float min_aspect: the smallest width divided by height, or 0 for no limit.
* float max_aspect: the largest width divided by height, or 0 for no limit.

## Returns:
bool: true on success, false otherwise.

## Remarks:
For example, setting both to 16.0 / 9.0 keeps the window widescreen.
