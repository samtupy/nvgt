# opSubAssign
Subtract another timespan or a number of microseconds from the timespan, as in `t -= 5 * SECONDS`.

1. `timespan& timespan::opSubAssign(const timespan&in other)`
2. `timespan& timespan::opSubAssign(int64 microseconds)`

## Arguments:
* const timespan&in other: the timespan to subtract (1).
* int64 microseconds: the number of microseconds to subtract (2).

## Returns:
timespan&: the timespan itself.
