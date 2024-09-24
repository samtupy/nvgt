# read_string
Reads the data by a given key.

`string settings::read_string(const string&in key, const string&in default_value = "");`

## Arguments:
* const string&in key: the key to look for.
* const string&in default_value = "": the value to return if the key could not be retrieved.

## Returns:
string: the data of the key or default value if the key could not be retrieved.
