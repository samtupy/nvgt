# opCmp
Compare the length of the timespan with another timespan or a number of microseconds, which lets the comparison operators `<`, `>`, `<=` and `>=` be used.

1. `int timespan::opCmp(const timespan&in other) const`
2. `int timespan::opCmp(int64 microseconds) const`

## Arguments:
* const timespan&in other: the timespan to compare with (1).
* int64 microseconds: the length to compare with, in microseconds (2).

## Returns:
int: a negative number if the timespan is shorter, 0 if it is equal and a positive number if it is longer.
