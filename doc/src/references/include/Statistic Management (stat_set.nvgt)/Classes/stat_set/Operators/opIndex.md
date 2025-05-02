# opIndex
Allows for the easy access of stats with `[...]` syntax.

`stat@ stat_set::opIndex(const string&in stat_name) const;`

## Arguments:
* const string&in stat_name: the name of the stat you want to access.

## Returns:
stat@: a handle to a stat with the given name, or null if no stat could be found.
