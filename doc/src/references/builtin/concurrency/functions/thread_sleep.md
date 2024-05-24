# thread_sleep
Sleeps the thread it was called from, but can be interrupted.

`bool thread_sleep(uint milliseconds);`

## Arguments:
* uint milliseconds: the number of milliseconds to sleep the thread for.

## Returns:
bool: true if the thread slept for the full duration, false if it was interrupted by `thread.wake_up`.

## Remarks:
This function should only be called in the context of threads created within your script.
