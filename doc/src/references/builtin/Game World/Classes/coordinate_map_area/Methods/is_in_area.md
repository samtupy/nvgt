# is_in_area
Find out whether a position is in the area.

`bool coordinate_map_area::is_in_area(float x, float y, float z, float d = 0.0, coordinate_map_filter_callback@ filter_callback = null, int64 required_flags = 0, int64 excluded_flags = 0) const;`

## Arguments:
* float x: the x coordinate of the position.
* float y: the y coordinate of the position.
* float z: the z coordinate of the position.
* float d = 0.0: how far outside the area the position may be and still count.
* coordinate_map_filter_callback@ filter_callback = null: a function called for each area found, returning true to include it or false to skip it, or null to include every area.
* int64 required_flags = 0: only include areas whose flags have all of these bits set.
* int64 excluded_flags = 0: skip areas whose flags have any of these bits set.

## Returns:
bool: true if the position is in the area, taking its rotation into account, and the area passes the filters, false otherwise.
