# get_area
Get the area with the highest priority at a position.

`coordinate_map_area@ coordinate_map::get_area(float x, float y, float z, int priority = -1, float d = 0.0, coordinate_map_filter_callback@ filter_callback = null, int64 required_flags = 0, int64 excluded_flags = 0) const;`

## Arguments:
* float x: the x coordinate of the position.
* float y: the y coordinate of the position.
* float z: the z coordinate of the position.
* int priority = -1: if 0 or more, only areas with a priority lower than this are considered, which finds what is under the top area. -1 considers every area.
* float d = 0.0: how far around the position to search.
* coordinate_map_filter_callback@ filter_callback = null: a function called for each area found, returning true to include it or false to skip it, or null to include every area.
* int64 required_flags = 0: only include areas whose flags have all of these bits set.
* int64 excluded_flags = 0: skip areas whose flags have any of these bits set.

## Returns:
coordinate_map_area@: the area, or null if there is none at the position.

## Remarks:
This is the usual way to find out what the player is standing on or in.
