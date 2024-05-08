# dgets
Get a string value out of a dictionary.

`string dgets(dictionary@ the_dictionary, string key, string def = 0.0);`

## Arguments:
* dictionary@ the_dictionary: a handle to the dictionary to get the value from.
* string key: the key of the value to look up.
* string def = "": the value to return if the key wasn't found.

## Returns:
string: the value for the particular key in the dictionary, or the default value if not found.
