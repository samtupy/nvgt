# parse
Set the UUID by parsing a string.

`void uuid::parse(const string&in str);`

## Arguments:
* const string&in str: the UUID to parse, with or without hyphens.

## Remarks:
An exception is thrown if the string isn't a valid UUID, try_parse() returns false instead.
