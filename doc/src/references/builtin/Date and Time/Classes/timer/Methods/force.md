# force
Set the elapsed time of the timer to an exact value.

`void timer::force(int64 elapsed);`

## Arguments:
* int64 elapsed: the time that the timer should consider to have elapsed, in units of the timer's accuracy.

## Remarks:
The timer keeps counting from the new value, or stays at it if it is paused. This is the same as assigning to the elapsed property.
