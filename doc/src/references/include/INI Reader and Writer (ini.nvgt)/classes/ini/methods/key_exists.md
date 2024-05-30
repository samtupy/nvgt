# key_exists
Determine if a particular key exists in the INI data.

`bool ini::key_exists(string section, string key);`

## Arguments:
* string section: the name of the section to look for the key in.
* string key: the name of the key.

## Returns:
bool: true if the specified key exists, false otherwise.

## Remarks:
An error will be accessible from the error system if the given section doesn't exist.
