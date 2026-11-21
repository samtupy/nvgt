# accuracy
The number of microseconds in one unit of the timer's elapsed time.

`uint64 timer::accuracy;`

## Remarks:
This is MILLISECONDS (1000) unless `timer_default_accuracy` had been changed when the timer was created, and any of the constants listed in `Time Units` or an arbitrary number of microseconds can be used. Changing it afterwards doesn't change how much time has passed, only the unit in which elapsed, has_elapsed(), tick(), force() and adjust() work, so a timer that had 2000 milliseconds elapsed reports 2 after its accuracy is set to SECONDS.
