# secure_erase
Remove every entry with a name, overwriting their values in memory first.

`void name_value_collection::secure_erase(const string&in name);`

## Arguments:
* const string&in name: the name to remove, case insensitively.

## Remarks:
This is useful for values such as passwords and tokens, which shouldn't be left in memory after they are removed.
