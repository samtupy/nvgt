# find_first
Find the position of a substring from within a string.

`int string::find_first(const string &in search, uint start = 0);`

## Arguments:
* search: The string to search for.
* start: The index to start searching from. Default is 0 (beginning).

## Returns
The position where the substring starts if found, or -1 otherwise.

## Remarks
If the start is less than 0, -1 is returned.

This appears to be an alias for string::find.
