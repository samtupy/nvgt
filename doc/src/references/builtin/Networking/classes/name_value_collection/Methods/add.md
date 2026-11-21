# add
Add a name and value to the collection, even if the name is already in it.

`void name_value_collection::add(const string&in name, const string&in value);`

## Arguments:
* const string&in name: the name to add.
* const string&in value: the value to add.

## Remarks:
Some headers, such as Set-Cookie, may appear more than once, which this allows.
