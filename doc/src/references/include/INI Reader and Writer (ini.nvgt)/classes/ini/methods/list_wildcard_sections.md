# list_wildcard_sections
Returns all section names containing a wildcard identifier. This way if searching through a file containing many normal sections and a few wildcard sections, it is possible to query only the wildcards for faster lookup.

`string[]@ ini::list_wildcard_sections();`

## Returns:
string[]@: a handle to an array containing all the wildcard sections.
