# assign_directory
Replace the path with a directory, treating the string as a directory even if it doesn't end with a separator.

1. `spec::path& path::assign_directory(const string&in directory);`
2. `spec::path& path::assign_directory(const string&in directory, spec::path_style style);`

## Arguments:
* const string&in directory: the directory to parse.
* spec::path_style style (2): how to parse the directory, a value of the path_style enum.

## Returns:
spec::path&: this path, so calls can be chained.
