# get
Get the value of a name, or a default value if it isn't in the collection.

`string name_value_collection::get(const string&in name, const string&in default_value = "") const;`

## Arguments:
* const string&in name: the name to look up, case insensitively.
* const string&in default_value = "": the value to return if the name isn't in the collection.

## Returns:
string: the value of the first entry with the name, or default_value.

## Remarks:
Indexing the collection, as in `c["name"]`, also returns the value of a name, but throws an exception if it isn't there.
