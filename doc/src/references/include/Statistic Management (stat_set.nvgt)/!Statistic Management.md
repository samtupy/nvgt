# Statistic Management
The stat_set include keeps track of named game statistics, such as kills, play time or a player's name, and makes them easy to update, display and save.

A `stat_set` holds any number of `stat` objects, each identified by a name. Every stat stores a value of any type in a `var`, plus a text template or callback that controls how the stat is displayed. Converting a stat to a string gives its display text, and converting a whole stat_set to a `string[]` gives the display text of every stat in the order they were added, ready to be shown in a menu or spoken.

Stats can be saved with `serialize()` and loaded with `deserialize()`, or written as simple `name=value` lines with `serialize_linear()`.

## Example
```NVGT
#include "stat_set.nvgt"

void main() {
	stat_set stats;
	stats.add("kills", 0, "Enemies defeated: %0");
	stats.add("deaths", 0, "Deaths: %0");
	stats.add("name", "Alex", "Player: %0");
	// Simulate a short game.
	for (int i = 0; i < 5; i++) stats["kills"]++;
	stats["deaths"]++;
	string[] lines = stats;
	alert("Statistics", join(lines, "\r\n"));
}
```
