# reset
Remove every area from the map.

`void coordinate_map::reset();`

## Remarks:
Areas that the script still holds handles to continue to exist, but are no longer in the map, and can be put back with coordinate_map_area::reframe().
