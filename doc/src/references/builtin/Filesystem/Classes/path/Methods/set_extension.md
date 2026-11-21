# set_extension
Set the extension of the path's filename.

`spec::path& path::set_extension(const string&in extension);`

## Arguments:
* const string&in extension: the new extension, without the dot. An empty extension removes it.

## Returns:
spec::path&: this path, so calls can be chained.
