# set
Set the value of a name, replacing the existing value if the name is already in the collection.

`void name_value_collection::set(const string&in name, const string&in value);`

## Arguments:
* const string&in name: the name to set. Names are case insensitive.
* const string&in value: the value to set.

## Remarks:
Assigning to an index, as in `c["name"] = "value";`, does the same.
