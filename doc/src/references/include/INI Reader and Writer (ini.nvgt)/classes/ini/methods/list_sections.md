# list_sections
List all section names that exist.

`string[]@ list_sections(bool include_blank_section = false);`

## Arguments:
* bool include_blank_section = false: Set this argument to true if you wish to include the empty element at the beginning of the list for the keys that aren't in sections, for example for automatic data collection so you don't have to insert yourself when looping through.

## Returns:
string[]@: a handle to an array containing all the key names.
