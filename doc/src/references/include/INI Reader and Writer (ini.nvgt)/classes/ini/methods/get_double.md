# get_double
Fetch a double from the INI data given a section and key.

`double ini::get_double(string section, string key, double default_value = 0.0);`

## Arguments:
* string section: the section to get the value from (if any).
* string key: the key of the value.
* double default_value = 0.0: the default value to return if the key isn't found.

## Returns:
double: the value at the particular key if found, the default value if not.

## Remarks:
All getters will use this format, and if one returns a default value (blank string, an int that equals 0, a boolean that equals false etc), and if you want to know whether the key actually existed, use the error checking system.
