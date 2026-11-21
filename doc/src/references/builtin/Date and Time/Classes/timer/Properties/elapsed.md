# elapsed
The amount of time that has passed since the timer was created or last restarted, not counting any time spent paused.

`int64 timer::elapsed;`

## Remarks:
The value is in units of the timer's accuracy, which is milliseconds by default, and is rounded down. Assigning to this property is the same as calling force().

The value can be negative if the timer was created with a negative initial_elapsed or adjusted below zero.
