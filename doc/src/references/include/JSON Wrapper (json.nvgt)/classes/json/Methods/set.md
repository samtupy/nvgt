# set
Set a value in the JSON data.

1. `bool json::set(string key, var@ value);`
2. `bool json::set(string key, json@ value);`

## Arguments:
- `string key`: The key to set.
- `var@ value`: The value to set.

## Returns:
`bool`: `true` if the value was successfully written, `false` otherwise.
