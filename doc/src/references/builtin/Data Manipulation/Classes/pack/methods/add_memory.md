# add_memory
Add content stored in memory to a pack.

`bool pack::add_memory(string pack_filename, string data, bool replace = false);`

## Arguments:
* string pack_filename: the name the file should have in your pack.
* string data: a string containing the data to be added.
* bool allow_replace = false: if a file already exists in the pack with that name, should it be overwritten?

## Returns:
bool: true if the data was successfully added, false otherwise.
