# push_directory
Add a directory to the end of the path's directories.

`spec::path& path::push_directory(const string&in directory_name);`

## Arguments:
* const string&in directory_name: the directory to add. `.` is ignored and `..` removes the last directory if there is one.

## Returns:
spec::path&: this path, so calls can be chained.
