# make_parent
Change the path to its parent directory.

`spec::path& path::make_parent();`

## Returns:
spec::path&: this path, so calls can be chained.

## Remarks:
A file becomes the directory it is in, and a directory loses its last directory. A relative path with no directories left gets a `..` directory.
