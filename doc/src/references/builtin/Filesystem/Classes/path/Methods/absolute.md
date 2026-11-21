# absolute
Get an absolute version of the path, leaving this one unchanged.

1. `spec::path path::absolute() const;`
2. `spec::path path::absolute(const spec::path&in base) const;`

## Arguments:
* const spec::path&in base (2): the absolute path to resolve against. Without it, the current working directory is used.

## Returns:
spec::path: the absolute path, or a copy of this path if it is already absolute.
