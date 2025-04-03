# dump
Dump all loaded data into a string.

`string toml::dump(bool indent = true);`

## Arguments:
- `bool indent = true`: If this is set to true, all keys in every section will be proceeded with a tab character in the output. This indent number will increase if you have nested subsections, e.g. `game.server.name` will have 2 tabs on its key, `name`.

## Returns:
`string`: The entire TOML data as a string.
