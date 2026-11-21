# is_slope_too_steep
Check whether a surface is too steep for the character to stand on.

`bool physics_character::is_slope_too_steep(const vector&in normal) const;`

## Arguments:
* const vector&in normal: the direction the surface faces.

## Returns:
bool: true if a surface with this normal is steeper than `max_slope_angle`.
