# set
Change the bounds and rotation of the area, moving it within the map.

`void coordinate_map_area::set(float minx, float maxx, float miny, float maxy, float minz, float maxz, float theta);`

## Arguments:
* float minx: the lowest x tile.
* float maxx: the highest x tile.
* float miny: the lowest y tile.
* float maxy: the highest y tile.
* float minz: the lowest z tile.
* float maxz: the highest z tile.
* float theta: the rotation around the area's center in radians.

## Remarks:
This is how doors that open and platforms that move are made.
