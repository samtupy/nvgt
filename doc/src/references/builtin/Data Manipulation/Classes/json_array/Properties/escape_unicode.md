# escape_unicode
Determines the amount of escaping that occurs in JSON parsing.

`bool json_array::escape_unicode;`

## Remarks:
If this property is true, escaping will behave like normal. If it's false, only the characters absolutely vital to JSON parsing are escaped.
