# delete_key
Delete a key from a given section.

`bool ini::delete_key(string section, string key);`

## Arguments:
* string section: the name of the section the key is stored in (if any).
* string key: the name of the key to delete.

## Returns:
bool: true if the key was successfully deleted, false and sets an error if the key you want to delete doesn't exist or if the key name is invalid.
