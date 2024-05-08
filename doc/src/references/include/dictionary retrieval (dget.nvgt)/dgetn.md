# dgetn
Get a numeric value out of a dictionary.

`double dgetn(dictionary@ the_dictionary, string key, double def = 0.0);`

## Arguments:
* dictionary@ the_dictionary: a handle to the dictionary to get the value from.
* string key: the key of the value to look up.
* double def = 0.0: the value to return if the key wasn't found.

## Returns:
double: the value for the particular key in the dictionary, or the default value if not found.
