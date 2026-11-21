# has_elapsed
Check whether at least a given amount of time has passed on the timer.

`bool timer::has_elapsed(int64 time_units);`

## Arguments:
* int64 time_units: the amount of time to check for, in units of the timer's accuracy.

## Returns:
bool: true if elapsed is greater than or equal to time_units.

## Remarks:
This doesn't change the timer, so it keeps counting. Use tick() to also start the timer over.
