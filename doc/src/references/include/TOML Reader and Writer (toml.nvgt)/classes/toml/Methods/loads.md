# loads
This function loads TOML data stored as a string, doing it this way insures that TOML data can come from any source, e.g. dynamic string.

`bool toml::loads(string str);`

## Arguments:
- `string str`: The TOML data to load (as a string).

## Returns:
`bool`: `true` if the data was successfully loaded, `false` otherwise.
