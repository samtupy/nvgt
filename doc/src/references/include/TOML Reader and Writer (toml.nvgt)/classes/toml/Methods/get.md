# get
Fetch a value from the TOML data given a section and key.

`var@ toml::get(string section, string key = "", var@ def = null);`

## Arguments:
- `string section`: The section to get the value from (if any). E.g. game.server
- `string key = ""`: The key to get.
- `var@ def = null`: The default value to facilitate handling by having an alternative value in case the original value ends up in failure.

## Returns:
`var@`: The value at the particular key if found, the default value otherwise.
