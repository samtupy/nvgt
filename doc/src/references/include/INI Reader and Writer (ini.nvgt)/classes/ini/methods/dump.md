# dump
Dump all loaded data into a string, such as what's used by the save function, or so that you can encrypt it, pack it or such things.

`string ini::dump(bool indent = false);`

## Arguments:
* bool indent = false:  If this is set to true, all keys in every named section will be proceeded with a tab character in the final output.

## Returns:
string: the entire INI data as a string.
