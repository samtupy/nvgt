# get
Fetch a value from the JSON data.

`var@ json::get(string key, var@ def = null);`

## Arguments:
- `string key`: The key to get.
- `var@ def = null`: The default value to facilitate handling by having an alternative value in case the original value ends up in failure.

## Returns:
`var@`: The value at the particular key if found, the default value otherwise.
