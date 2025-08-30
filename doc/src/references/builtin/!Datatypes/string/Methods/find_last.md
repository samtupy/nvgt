# find_last
Find the position of a substring from within a string, searching right to left.

`int string::find_last(const string &in search, uint start = -1);`

## Arguments:
* search: The string to search for.
* start: The index to start searching from. Default is -1 (end).

## Returns
The position where the substring starts if found, or -1 otherwise.

## Remarks
This is useful if what you need to find is closer to the end of a string than the start.

This appears to be an alias for string::rfind.
