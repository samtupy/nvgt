# read_file
Get the contents of a file contained in a pack.

`string pack::read_file(const string&in pack_filename, uint offset_in_file, uint size);`

## Arguments:
* const string&in pack_filename: the name of the file to be read.
* uint offset_in_file: the offset within the file to begin reading data from (do not confuse this with pack::get_file_offset)
* uint size: the number of bytes to read (see `pack::get_file_size` to read the entire file).

## Returns:
string: the contents of the file.

## Remarks:
This function allows you to read chunks of data from a file, as well as an entire file in one call. To facilitate this, the offset and size parameters are provided. offset is relative to the file being read E. 0 for the beginning of it. So to read a file in one chunk, you could execute:
```
string file_contents = my_pack.read_file("filename", 0, my_pack.get_file_size("filename"));
```
