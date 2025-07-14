# find_last_not_of
Find the first occurrence of any character that is not present in the search string, searching from right to left.

`int string::find_last_not_of(const string &in search, uint start = 0);`

## Arguments:
* search: The characters to exclude in a match.
* start: The index to start searching from. Default is -1 (end).

## Returns
The position where a match was found, or -1 otherwise.

## Remarks
This can be useful in several scenarios, such as splitting strings or quickly finding out if your string has invalid characters. A scenario where this could be useful is if you are finding parts of a URL or path, you might want to `find_last_not_of(":\\/.")`.
