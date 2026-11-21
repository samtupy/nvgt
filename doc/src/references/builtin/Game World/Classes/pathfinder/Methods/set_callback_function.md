# set_callback_function
Set the function that says how difficult each tile is to cross.

1. `void pathfinder::set_callback_function(pathfinder_callback@ callback);`
2. `void pathfinder::set_callback_function(pathfinder_callback_ex@ callback);`
3. `void pathfinder::set_callback_function(pathfinder_callback_legacy@ callback);`

## Arguments:
* pathfinder_callback@ callback: the function, which returns 0 to 9 for a tile that can be crossed, with higher numbers being more difficult, or 10 or more for one that can't. It can take the coordinates of the tile and the callback_data given to find(), and also the tile the search is coming from, the parent, for terrain whose difficulty depends on the direction of travel.

## Remarks:
Callbacks that take the parent tile, pathfinder_callback_ex and pathfinder_callback_legacy, can't be used with caching, and an exception is thrown if the pathfinder was created with cache set to true. The legacy callback is for code ported from BGT, used with the 2D find().
