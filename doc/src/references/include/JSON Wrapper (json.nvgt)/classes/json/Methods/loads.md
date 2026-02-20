# loads
This function loads JSON data stored as a string, doing it this way insures that the data can come from any source, e.g. dynamic string.

`bool json::loads(string str);`

## Arguments:
- `string str`: The JSON data to load (as a string).

## Returns:
`bool`: `true` if the data was successfully loaded, `false` otherwise.
