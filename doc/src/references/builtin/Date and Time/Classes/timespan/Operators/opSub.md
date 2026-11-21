# opSub
Return the difference between the timespan and another timespan or a number of microseconds.

1. `timespan timespan::opSub(const timespan&in other) const`
2. `timespan timespan::opSub(int64 microseconds) const`

## Arguments:
* const timespan&in other: the timespan to subtract (1).
* int64 microseconds: the number of microseconds to subtract (2).

## Returns:
timespan: the new timespan, leaving this one unchanged.
