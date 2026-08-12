# load
Load a TOML file / stream.

1. `bool toml::load(string filename);`
2. `bool toml::load(datastream@ f);`

## Arguments (1):
- `string filename`: The name of the TOML file to load.

## Arguments (2):
- `datastream@ f`: A stream (i.e the file object) that is ready to be read.

## Returns:
`bool`: `true` if the TOML data was successfully loaded, `false` otherwise.
