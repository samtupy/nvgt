# opAddAssign
Add another timespan or a number of microseconds to the timespan, as in `t += 5 * SECONDS`.

1. `timespan& timespan::opAddAssign(const timespan&in other)`
2. `timespan& timespan::opAddAssign(int64 microseconds)`

## Arguments:
* const timespan&in other: the timespan to add (1).
* int64 microseconds: the number of microseconds to add (2).

## Returns:
timespan&: the timespan itself.
