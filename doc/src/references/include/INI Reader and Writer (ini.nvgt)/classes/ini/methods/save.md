# save
Save everything currently loaded to a file.

`bool ini::save(string filename, bool indent = false);`

## Arguments:
* string filename: the name of the file to write to.
* bool indent = false:  If this is set to true, all keys in every named section will be proceeded with a tab character in the final output.

## Returns:
bool: true if the data was successfully saved, false otherwise.
