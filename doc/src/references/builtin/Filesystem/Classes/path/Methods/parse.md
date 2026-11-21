# parse
Replace the path by parsing a string, without throwing an exception if it isn't valid.

1. `bool path::parse(const string&in path);`
2. `bool path::parse(const string&in path, spec::path_style style);`

## Arguments:
* const string&in path: the path to parse.
* spec::path_style style (2): how to parse the path, a value of the path_style enum.

## Returns:
bool: true if the path was valid, false otherwise, in which case the path is unchanged.
