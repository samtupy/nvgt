# add
Adds a stat to the set.

`stat@ stat_set::add(const string&in name, var@ value, const string&in text = "", stat_callback@ callback = null, dictionary@ user = null);`

## Arguments:
* const string&in name: the name of the stat to add.
* var@ value: the starting value for this stat.
* const string&in text = "": an optional text template to be used when getting the value of this stat. In this template, use %0 anywhere you want to output the raw value of the stat itself.
* stat_callback@ callback = null: an optional callback to call every time the value of this stat is requested. One of text or callback has to be provided in order for a stat to work correctly.
* dictionary@ user = null: Not touched by the stat_set itself, allows the linkage of any user values to a stat to help with display.

## Returns:
stat@: a handle to the newly added stat object.
