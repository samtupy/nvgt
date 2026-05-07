# get
Fetch a value from the TOML data given a key.

`var@ toml_section::get(string key, var@ def = null);`

## Arguments:
- `string key`: The key to get.
- `var@ def = null`: The default value if the key could not be retrieved.

## Returns:
`var@`: The value at the particular key if found, the default value otherwise.
