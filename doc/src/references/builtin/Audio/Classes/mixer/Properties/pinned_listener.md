# pinned_listener
The index of a listener that the mixer is always heard from, regardless of which listener is closest.

`uint mixer::pinned_listener;`

## Remarks:
This only matters in an engine with more than one listener, such as a split screen game. By default a mixer is heard from the closest listener.
