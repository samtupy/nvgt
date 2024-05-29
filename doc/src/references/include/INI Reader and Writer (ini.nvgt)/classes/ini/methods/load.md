# load
Load an INI file.

`bool ini::load(string filename, bool robust = true);`

## Arguments:
* string filename: the name of the ini file to load.
* bool robust = true: if true, a tempoerary backup copy of the ini data will be created before saving, and it'll be restored on error. This is slower and should only be used when necessary, but insures 0 data loss.

## Returns:
bool: true if the ini data was successfully loaded, false otherwise.
