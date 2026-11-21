# search_range
How far from the start a search may go on each axis, or 0 for no limit.

`int pathfinder::search_range;`

## Remarks:
Limiting the range stops a search for an unreachable destination from exploring an entire large map. A destination further away than this has no path.
