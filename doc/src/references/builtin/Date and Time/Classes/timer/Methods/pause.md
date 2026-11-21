# pause
Stop the timer from counting until it is resumed.

`bool timer::pause();`

## Returns:
bool: true if the timer was running and is now paused, false if it was already paused.

## Remarks:
The elapsed time is kept while the timer is paused, and counting continues from it after resume().
