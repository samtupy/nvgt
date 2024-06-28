# replace
Try to find any occurrences of a particular string, and replace them with a substitution in a given string object.

`string string::replace(string search, string replacement, bool replace_all = true);`

## Arguments:
* string search: the string to search for.
* string replacement: the string to replace the search text with (if found).
* bool replace_all = true: whether or not all occurrences should be replaced, or only the first one.

## Returns:
string: the specified string with the replacement applied.
