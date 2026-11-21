# opEquals
Check whether the timespan is the same length as another timespan or a number of microseconds.

1. `bool timespan::opEquals(const timespan&in other) const`
2. `bool timespan::opEquals(int64 microseconds) const`

## Arguments:
* const timespan&in other: the timespan to compare with (1).
* int64 microseconds: the length to compare with, in microseconds (2).

## Returns:
bool: true if the lengths are equal.
