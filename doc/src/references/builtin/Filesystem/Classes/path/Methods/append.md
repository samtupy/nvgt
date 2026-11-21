# append
Add a relative path to the end of this one.

`spec::path& path::append(const spec::path&in path);`

## Arguments:
* const spec::path&in path: the path to add, whose directories and filename follow this path's directories.

## Returns:
spec::path&: this path, so calls can be chained.

## Remarks:
The `/` operator does the same without changing either path.
