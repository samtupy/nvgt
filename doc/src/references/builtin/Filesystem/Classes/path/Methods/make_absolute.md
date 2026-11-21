# make_absolute
Make the path absolute by resolving it against a base path, if it is relative.

1. `spec::path& path::make_absolute();`
2. `spec::path& path::make_absolute(const spec::path&in base);`

## Arguments:
* const spec::path&in base (2): the absolute path to resolve against. Without it, the current working directory is used.

## Returns:
spec::path&: this path, so calls can be chained.
