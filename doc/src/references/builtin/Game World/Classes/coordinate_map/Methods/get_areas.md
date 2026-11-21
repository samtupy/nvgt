# get_areas
Get every area at a position, or within a box.

1. `array<coordinate_map_area@>@ coordinate_map::get_areas(float x, float y, float z, float d = 0.0, coordinate_map_filter_callback@ filter_callback = null, int64 required_flags = 0, int64 excluded_flags = 0) const;`
2. `array<coordinate_map_area@>@ coordinate_map::get_areas(float minx, float maxx, float miny, float maxy, float minz, float maxz, float d = 0.0, coordinate_map_filter_callback@ filter_callback = null, int64 required_flags = 0, int64 excluded_flags = 0) const;`

## Arguments:
* float x (1): the x coordinate of the position.
* float y (1): the y coordinate of the position.
* float z (1): the z coordinate of the position.
* float d = 0.0: how far around the position or box to search, which finds areas within this distance of it.
* coordinate_map_filter_callback@ filter_callback = null: a function called for each area found, returning true to include it or false to skip it, or null to include every area.
* int64 required_flags = 0: only include areas whose flags have all of these bits set.
* int64 excluded_flags = 0: skip areas whose flags have any of these bits set.
* float minx (2): the lowest x of the box to search.
* float maxx (2): the highest x of the box to search.
* float miny (2): the lowest y of the box to search.
* float maxy (2): the highest y of the box to search.
* float minz (2): the lowest z of the box to search.
* float maxz (2): the highest z of the box to search.

## Returns:
array<coordinate_map_area@>@: the areas found. For a position they are sorted by priority, lowest first. For a box, only areas lying entirely within it, expanded by d, are returned.

## Remarks:
Searching with a distance is useful for finding what is near the player, such as walls to warn them about or objects they could pick up.
