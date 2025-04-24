# insert
Insert a string into another string at a given position.

`void string::insert(uint pos, const string&in other);`

## Arguments:
* uint pos: the index to insert the other string at.
* const string&in other: the string to insert.

## Remarks
Please note this modifies the calling string. To keep the original you will need to make a copy.

if pos is out of bounds, an exception is thrown.
