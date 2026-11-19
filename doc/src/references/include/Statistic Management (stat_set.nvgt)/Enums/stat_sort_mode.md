# stat_sort_mode
The orders that `stat_set::list()` can return stat names in.

* STAT_SORT_MODE_NONE: no particular order. This is the fastest, but the order can change as stats are added and removed.
* STAT_SORT_MODE_ADD_ORDER: the order in which the stats were added.
* STAT_SORT_MODE_VALUE: from the lowest value to the highest. Use this only when every stat in the set holds a number.
