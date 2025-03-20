# set
Set a value in the TOML data given a key and a value.

`bool toml_section::set(string key, any@ value);`

## Arguments:
- `string key`: The key to set.
- `any@ value`: The value to set. Supported types are the same with the ones in the `toml` class

## Returns:
`bool`: `true` if the value was successfully written, `false` otherwise.
