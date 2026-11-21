# reset
Forget the tile difficulties and paths cached by previous searches.

`void pathfinder::reset();`

## Remarks:
Call this whenever the map changes, such as when a door opens. If called from within the callback, the reset happens once the search ends.
