# dgetsl
Get a string array out of a dictionary.

`string[] dgetsl(dictionary@ the_dictionary, string key, string[] def = []);`

## Arguments:
* dictionary@ the_dictionary: a handle to the dictionary to get the value from.
* string key: the key of the value to look up.
* string[] def = []: the value to return if the key wasn't found.

## Returns:
string[]: the value for the particular key in the dictionary, or the default value if not found.

## Remarks:
The default value for this function is a completely empty (but initialized) string array.
