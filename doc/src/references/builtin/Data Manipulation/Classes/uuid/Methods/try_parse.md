# try_parse
Set the UUID by parsing a string, without throwing an exception if it isn't valid.

`bool uuid::try_parse(const string&in str);`

## Arguments:
* const string&in str: the UUID to parse, with or without hyphens.

## Returns:
bool: true if the string was a valid UUID, false otherwise, in which case the UUID is unchanged.
