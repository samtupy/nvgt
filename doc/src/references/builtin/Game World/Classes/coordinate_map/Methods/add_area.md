# add_area
Add an area to the map.

`coordinate_map_area@ coordinate_map::add_area(float minx, float maxx, float miny, float maxy, float minz, float maxz, float rotation, any@ primary_data, const string&in data1, const string&in data2, const string&in data3, int priority, int64 flags = 0);`

## Arguments:
* float minx: the lowest x tile of the area.
* float maxx: the highest x tile of the area, which is included in it.
* float miny: the lowest y tile of the area.
* float maxy: the highest y tile of the area.
* float minz: the lowest z tile of the area.
* float maxz: the highest z tile of the area.
* float rotation: how far the area is rotated around its center on the x y plane, in radians, or 0 for none.
* any@ primary_data: any value or handle to store with the area, such as the object it represents, or null.
* const string&in data1: a string to store with the area, such as the name of its surface or sound.
* const string&in data2: another string to store with the area.
* const string&in data3: another string to store with the area.
* int priority: the priority of the area. Where areas overlap, get_area() returns the one with the highest priority.
* int64 flags = 0: bits of your choosing that searches can require or exclude, such as one bit for solid areas and another for water.

## Returns:
coordinate_map_area@: the new area, which is already in the map.

## Remarks:
The data and flags can be anything a game needs. A common pattern is to store the type of the area, such as a surface or a wall, in data1, and a handle to a script object with more information in primary_data.
