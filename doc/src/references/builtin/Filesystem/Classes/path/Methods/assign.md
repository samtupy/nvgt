# assign
Replace the path by parsing a string, or copying another path.

1. `spec::path& path::assign(const string&in path);`
2. `spec::path& path::assign(const string&in path, spec::path_style style);`
3. `spec::path& path::assign(const spec::path&in other);`

## Arguments:
* const string&in path (1, 2): the path to parse.
* spec::path_style style (2): how to parse the path, a value of the path_style enum.
* const spec::path&in other (3): the path to copy.

## Returns:
spec::path&: this path, so calls can be chained.

## Remarks:
An exception is thrown if the string isn't a valid path. parse() returns false instead.
