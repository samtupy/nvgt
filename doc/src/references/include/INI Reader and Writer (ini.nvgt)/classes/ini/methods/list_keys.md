# list_keys
List all key names in a given section.

`string[]@ ini::list_keys(string section);`

## Arguments:
* string section: the section to list keys from(pass a blank string for all sectionless keys as usual).

## Returns:
string[]@: a handle to an array containing all the keys.  An empty array means that the section is either blank or doesn't exist, the latter being able to be checked with the error system.
