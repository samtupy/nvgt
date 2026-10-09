# update
Updates a particular stat with a new value.

`void stat_set::update(const string&in name, var@ value);`

## Arguments:
* const string&in name: the name of the stat to be updated.
* var@ value: the new value of the stat.

## Remarks:
Nothing happens if there is no stat with the given name. Use `add()` to create a stat.
