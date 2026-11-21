# get_aspect_ratio
Get the range of aspect ratios the window's client area is kept within when resized.

`bool game_window::get_aspect_ratio(float&out min_aspect, float&out max_aspect) const;`

## Arguments:
* float&out min_aspect: receives the smallest width divided by height, or 0 for no limit.
* float&out max_aspect: receives the largest width divided by height, or 0 for no limit.

## Returns:
bool: true on success, false otherwise.
