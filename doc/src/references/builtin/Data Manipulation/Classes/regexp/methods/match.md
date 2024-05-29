# match
Determine if the regular expression matches against a particular string or not.

1. `bool regexp::match(string subject, uint64 offset = 0);`
2. `bool regexp::match(string subject, uint64 offset, int options);`

## Arguments (1):
* string subject: the string to compare against.
* uint64 offset = 0: the offset to start the comparison at.

## Arguments (2):
* string subject: the string to compare against.
* uint64 offset: the offset to start the comparison at.
* int options: any combination of the values found in the `regexp_options` enum.

## Returns:
bool: true if the regular expression matches the given string, false if not.
