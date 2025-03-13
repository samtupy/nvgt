# load
Load a TOML file.

1. `bool toml::load(string filename);`
2. `bool toml::load(file@ f);`

## Arguments (1):
- `string filename`: The name of the TOML file to load.

## Arguments (2):
- `file@ f`: The file object that is ready to be read.

## Returns:
`bool`: `true` if the TOML data was successfully loaded, `false` otherwise.
