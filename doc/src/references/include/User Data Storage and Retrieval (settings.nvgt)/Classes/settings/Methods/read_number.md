# read_number
Reads the data by a given key, number as value.

`double settings::read_number(const string&in key, double default_value = 0);`

## Arguments:
* const string&in key: the key to look for.
* double default_value = 0: the value to return if the key could not be retrieved.

## Returns:
double: the data of the key or default value if the key could not be retrieved.
