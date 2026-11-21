# resolve
Resolve a path against this one, which replaces this path if it is absolute, or is appended to it if it is relative.

`spec::path& path::resolve(const spec::path&in path);`

## Arguments:
* const spec::path&in path: the path to resolve.

## Returns:
spec::path&: this path, so calls can be chained.
