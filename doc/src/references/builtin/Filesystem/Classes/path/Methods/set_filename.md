# set_filename
Set the filename of the path, including its extension.

`spec::path& path::set_filename(const string&in filename);`

## Arguments:
* const string&in filename: the filename to set. An empty filename makes the path a directory.

## Returns:
spec::path&: this path, so calls can be chained.
