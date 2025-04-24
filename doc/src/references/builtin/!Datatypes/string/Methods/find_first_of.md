# find_first_of
Find the first occurrence of any character in the search string.

`int string::find_first_of(const string &in search, uint start = 0);`

## Arguments:
* search: A string of characters to search for.
* start: The index to start searching from. Default is 0 (beginning).

## Returns
The position where a match was found, or -1 otherwise.

## Remarks
Where find and find_first will find an occurrence of an entire substring, this will match any character. This is useful, for instance, if you need to search for delimiters before splitting.
