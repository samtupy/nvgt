# wait
waits for the event to become signaled, blocking indefinitely or for a given duration if required.

1. `void wait();`
2. `void wait(uint milliseconds);`

## Arguments (2):
* uint milliseconds: How long to wait for the event to become signaled before throwing an exception

## Remarks:
Beware that if you use the version of the wait function that takes a timeout argument, an exception will be thrown if the timeout expires without the event having become signaled. The version of the function taking 0 arguments waits forever for the event's set() method to be called.
