# cancel
Stop the search in progress, so that find() returns an empty path.

`void pathfinder::cancel();`

## Remarks:
This is for calling from within the callback, such as when a search is taking too long.
