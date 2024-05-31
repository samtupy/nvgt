# get_string
Fetch a string from the INI data given a section and key.

`string ini::get_string(string section, string key, string default_value = "");`

## Arguments:
* string section: the section to get the value from (if any).
* string key: the key of the value.
* string default_value = "": the default value to return if the key isn't found.

## Returns:
string: the value at the particular key if found, the default value if not.

## Remarks:
All getters will use this format, and if one returns a default value (blank string, an int that equals 0, a boolean that equals false etc), and if you want to know whether the key actually existed, use the error checking system.
