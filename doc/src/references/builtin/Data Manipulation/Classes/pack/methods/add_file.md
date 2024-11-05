# add_file
Add a file on disk to a pack.

`bool pack::add_file(const string&in disk_filename, const string&in pack_filename, bool allow_replace = false);`

## Arguments:
* const string&in disk_filename: the filename of the file to add to the pack.
* const string&in pack_filename: the name the file should have in your pack.
* bool allow_replace = false: if a file already exists in the pack with that name, should it be overwritten?

## Returns:
bool: true if the file was successfully added, false otherwise.
