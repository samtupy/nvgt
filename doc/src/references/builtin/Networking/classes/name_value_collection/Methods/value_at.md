# value_at
Get the value of an entry by its position.

`const string& name_value_collection::value_at(uint index) const;`

## Arguments:
* uint index: the position of the entry, from 0 to size() - 1.

## Returns:
const string&: the value of the entry.

## Remarks:
An exception is thrown if the index is out of range.
