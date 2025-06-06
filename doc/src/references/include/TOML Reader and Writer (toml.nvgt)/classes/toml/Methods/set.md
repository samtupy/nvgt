# set
Set a value in the TOML data given a section name, a key and a value.

`bool toml::set(string section, string key = "", any@ value = null);`

## Arguments:
- `string section`: The section to put this key/value pair in (leave blank to add at the top of the file without a section).
- `string key = ""`: The key to set.
- `any@ value = null`: The value to set, see main  TOML Reader introduction for supported types. Unsupported type of value always returns `false`.

## Returns:
`bool`: `true` if the value was successfully written, `false` otherwise.
