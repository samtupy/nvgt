# get_bool
Fetch a boolean value from the INI data given a section and key.

`bool ini::get_bool(string section, string key, bool default_value = false);`

## Arguments:
* string section: the section to get the value from (if any).
* string key: the key of the value.
* bool default_value = aflse: the default value to return if the key isn't found.

## Returns:
bool: the value at the particular key if found, the default value if not.

## Remarks:
All getters will use this format, and if one returns a default value (blank string, an int that equals 0, a boolean that equals false etc), and if you want to know whether the key actually existed, use the error checking system.
