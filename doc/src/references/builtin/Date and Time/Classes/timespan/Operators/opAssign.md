# opAssign
Set the timespan to another timespan or to a number of microseconds.

1. `timespan& timespan::opAssign(const timespan&in other)`
2. `timespan& timespan::opAssign(int64 microseconds)`

## Arguments:
* const timespan&in other: the timespan to copy (1).
* int64 microseconds: the new length, in microseconds (2).

## Returns:
timespan&: the timespan itself.
