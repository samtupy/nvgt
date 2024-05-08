# dgetb
Get a boolean value out of a dictionary.

`bool dgetn(dictionary@ the_dictionary, string key, bool def = false);`

## Arguments:
* dictionary@ the_dictionary: a handle to the dictionary to get the value from.
* string key: the key of the value to look up.
* bool def = false: the value to return if the key wasn't found.

## Returns:
bool: the value for the particular key in the dictionary, or the default value if not found.
