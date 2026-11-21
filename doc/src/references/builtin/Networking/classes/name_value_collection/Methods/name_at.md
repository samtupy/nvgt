# name_at
Get the name of an entry by its position.

`const string& name_value_collection::name_at(uint index) const;`

## Arguments:
* uint index: the position of the entry, from 0 to size() - 1.

## Returns:
const string&: the name of the entry.

## Remarks:
An exception is thrown if the index is out of range. Together with value_at() and size(), this lets every entry be listed.
