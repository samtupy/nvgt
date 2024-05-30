# save_robust
This function is similar to `ini::save()`, but it first performs a temporary backup of any existing data, then restores that backup if the saving fails. This is slower and should only be used when necissary, but should insure 0 data loss.

`bool ini::save_robust(string filename, bool indent = false);`

## Arguments:
* string filename: the name of the file to write to.
* bool indent = false:  If this is set to true, all keys in every named section will be proceeded with a tab character in the final output.

## Returns:
bool: true if the data was successfully saved, false otherwise.
