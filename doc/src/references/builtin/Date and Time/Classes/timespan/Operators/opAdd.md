# opAdd
Return the sum of the timespan and another timespan or a number of microseconds.

1. `timespan timespan::opAdd(const timespan&in other) const`
2. `timespan timespan::opAdd(int64 microseconds) const`

## Arguments:
* const timespan&in other: the timespan to add (1).
* int64 microseconds: the number of microseconds to add (2).

## Returns:
timespan: the new timespan, leaving this one unchanged.
