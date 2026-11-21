# adjust
Add to or subtract from the elapsed time of the timer.

`void timer::adjust(int64 mod_elapsed);`

## Arguments:
* int64 mod_elapsed: the amount of time to add, in units of the timer's accuracy. A negative value subtracts time.

## Remarks:
This works on running and paused timers alike. For example `t.adjust(-500)` delays a repeating event that was about to fire by half a second.
