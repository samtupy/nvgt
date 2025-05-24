# find_last_of
Find the first occurrence of any character in the search string, searching right to left.

`int string::find_last_of(const string &in search, uint start = 0);`

## Arguments:
* search: a string of characters to search for.
* start: The index to start searching from. Default is -1 (end).

## Returns
The position where a match was found, or -1 otherwise.

## Remarks
Where find and find_last will find an occurrence of an entire substring, this will match any character. This is useful, for instance, if you need to search for delimiters before splitting.
