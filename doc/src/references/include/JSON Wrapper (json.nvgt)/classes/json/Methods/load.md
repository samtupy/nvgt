# load
Load a JSON file / stream.

1. `bool json::loadf(string filename);`
2. `bool json::loadds(datastream@ f);`

## Arguments (1):
- `string filename`: The name of the JSON file to load.

## Arguments (2):
- `datastream@ f`: A stream (i.e. the file object) that is ready to be read.

## Returns:
`bool`: `true` if the JSON data was successfully loaded, `false` otherwise.
