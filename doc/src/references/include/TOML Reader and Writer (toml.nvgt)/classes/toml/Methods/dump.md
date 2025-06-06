# dump
Dump all loaded data into a string.

`string toml::dump(bool indent = true, bool empty_sections = true);`

## Arguments:
- `bool indent = true`: If this is set to true, all keys in every section will be proceeded with a tab character in the output. This indent number will increase if you have nested subsections, e.g. `game.server.name` will have 2 tabs on its key, `name`.
- `bool empty_sections = true`: Should the data include empty sections? Default is usually ok.

## Returns:
`string`: The entire TOML data as a string.
