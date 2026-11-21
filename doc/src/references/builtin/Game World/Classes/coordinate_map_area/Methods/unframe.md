# unframe
Remove the area from its map, so searches no longer find it.

`void coordinate_map_area::unframe();`

## Remarks:
This is how an area is deleted from a map. The area is destroyed once the script no longer holds a handle to it, or can be put back with reframe().
