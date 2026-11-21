# find
Find the cheapest path between two tiles.

1. `array<vector>@ pathfinder::find(int start_x, int start_y, int start_z, int end_x, int end_y, int end_z, any@ callback_data = null);`
2. `array<vector>@ pathfinder::find(int start_x, int start_y, int end_x, int end_y, string user_data = "");`

## Arguments:
* int start_x: the x coordinate to start from.
* int start_y: the y coordinate to start from.
* int start_z (1): the z coordinate to start from.
* int end_x: the x coordinate to go to.
* int end_y: the y coordinate to go to.
* int end_z (1): the z coordinate to go to.
* any@ callback_data = null (1): a value or handle passed to every call of the callback, such as the map or character the path is for.
* string user_data = "" (2): a string passed to every call of a legacy callback.

## Returns:
array<vector>@: the tiles of the path in order, not including the start but including the destination, or an empty array if there is no path.

## Remarks:
There is no path when the start or end can't be crossed, every route is blocked, the destination is beyond search_range, no callback has been set, or a search is already in progress. total_cost holds the cost of the path found.

The 2D overload, which takes no z coordinates and a string of user data, is for code ported from BGT and only works with a legacy callback.
