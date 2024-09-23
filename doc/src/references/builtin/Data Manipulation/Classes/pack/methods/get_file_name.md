# get_file_name
Get the name of a file with a particular index.

`string pack::get_file_name(int index);`

## Arguments:
* int index: the index of the file to retrieve (see remarks).

## Returns:
string: the name of the file if found, or an empty string if not.

## Remarks:
The index you pass to this function is the same index you'd use to access an element in the return value from `pack::list_files()`.
