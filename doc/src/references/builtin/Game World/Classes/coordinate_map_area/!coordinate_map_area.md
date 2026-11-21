# coordinate_map_area
An area of a coordinate_map, a box of tiles with a priority, flags and data.



## Remarks:
Areas can't be created directly, they are created by coordinate_map::add_area(). Their bounds can only be changed with set(), set_area() and set_rotation(), which move them within the map.
