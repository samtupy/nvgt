# replace_this
Try to find any occurrences of a particular string, and replace them with a substitution in a given string object.

`string& string::replace_this(const string&in search, const string&in replacement, bool replace_all = true);`

## Arguments:
* const string&in search: the string to search for.
* const string&in replacement: the string to replace the search text with (if found).
* bool replace_all = true: whether or not all occurrences should be replaced, or only the first one.

## Returns:
string&: a two-way reference to the specified string with the replacement applied.
