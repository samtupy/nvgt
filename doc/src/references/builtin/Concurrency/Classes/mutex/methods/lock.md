# lock
Locks the mutex, waiting indefinitely or for a given duration if necessary for the operation to succeed.

1. `void lock();`
2. `void lock(uint milliseconds);`

## Arguments (2):
* uint milliseconds: How long to wait for a lock to succeed before throwing an exception

## Remarks:
With the mutex class in particular, it is safe to call the lock function on the same thread multiple times in a row so long as it is matched by the same number of unlock calls. This may not be the case for other types of mutexes.

Beware that if you use the version of the lock function that takes a timeout argument, an exception will be thrown if the timeout expires without a lock acquiring. The version of the function taking 0 arguments waits forever for a lock to succeed.
