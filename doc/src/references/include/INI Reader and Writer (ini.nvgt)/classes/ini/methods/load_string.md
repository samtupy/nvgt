# load_string
This function loads ini data stored as a string, doing it this way insures that ini data can come from any source, such as an encrypted string if need be.

`bool ini::load_string(string data, string filename = "*");`

## Arguments:
* string data: the INI data to load (as a string).
* string filename = "*": the new filename to set on the INI object, if any.

## Returns:
bool: true if the data was successfully loaded, false otherwise.

## Remarks:
Input data is expected to have CRLF line endings.
