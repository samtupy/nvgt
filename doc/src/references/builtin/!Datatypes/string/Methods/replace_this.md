# replace_this
Try to find any occurances of a particular string, and replace them with a substatution in a given string object.

`string& string::replace_this(string search, string replacement, bool replace_all = true);`

## Arguments:
* string search: the string to search for.
* string replacement: the string to replace the search text with (if found).
* bool replace_all = true: whether or not all occurances should be replaced, or only the first one.

## Returns:
string&: a two-way reference to the specified string with the replacement applied.
