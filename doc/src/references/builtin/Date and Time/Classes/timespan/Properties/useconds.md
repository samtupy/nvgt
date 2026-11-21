# useconds
The microseconds left over after removing whole seconds, from 0 to 999999.

`const int timespan::useconds;`

## Remarks:
Unlike microseconds, this includes the milliseconds. For a timespan of 5678 microseconds, microseconds is 678 and useconds is 5678.
