# desperation_factor
How much more willing the pathfinder is to cross difficult tiles, from 0 to 10.

`int pathfinder::desperation_factor;`

## Remarks:
This is subtracted from the difficulty of every tile that can be crossed, so that with a desperation factor of 5 a tile of difficulty 5 costs no more than open ground. Tiles of difficulty 10 or more stay impassable. Raising it after a search fails lets a character take a harder route rather than none.
