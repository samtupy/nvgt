# get_file_offset
Get the offset of a file in your pack.

`uint pack::get_file_offset(const string&in filename);`

## Arguments:
* const string&in filename: the name of the file to get the offset of.

## Returns:
uint: the offset of the file (in bytes).

## Remarks:
Do not confuse this with the offset parameter in the pack::read_file method. This function is provided encase you wish to re-open the pack file with your own file object and seek to a file's data within that external object. The offset_in_file parameter in the read_file method is relative to the file being read.
