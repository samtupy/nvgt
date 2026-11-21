# acquire_exclusive_lock
Take AngelScript's exclusive lock, which stops other threads from changing the engine's shared state until it is released.

`void acquire_exclusive_lock();`

## Remarks:
This is for advanced uses with threads, and must be followed by release_exclusive_lock(). Holding it while doing anything slow stalls every thread that needs the engine.
