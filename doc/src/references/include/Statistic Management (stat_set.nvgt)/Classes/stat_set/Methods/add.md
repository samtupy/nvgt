# add
Adds a stat to the set.

`stat@ stat_set::add(const string&in name, var@ value, const string&in text = "", stat_callback@ callback = null, dictionary@ user = null);`

## Arguments:
* const string&in name: the name of the stat to add.
* var@ value: the starting value for this stat.
* const string&in text = "": an optional text template used when displaying the stat, where `%0` is replaced with the stat's value. If empty, the stat displays just its value.
* stat_callback@ callback = null: an optional function that produces the stat's display text, for when a template isn't flexible enough. If null, `default_stat_callback` is used.
* dictionary@ user = null: optional data to attach to the stat. The set never reads it, and it isn't saved by `serialize()`.

## Returns:
stat@: a handle to the newly added stat, or null if the set already contains a stat with that name.
