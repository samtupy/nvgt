# read_file
Get the contents of a file contained in a pack.

`string pack::read_file(string pack_filename, uint offset, uint size);`

## Arguments:
* string pack_filename: the name of the file to be read.
* uint offset: the file's offset in the pack (see `pack::get_file_offset`).
* uint size: the size of the file (see `pack::get_file_size`).

## Returns:
string: the contents of the file.
