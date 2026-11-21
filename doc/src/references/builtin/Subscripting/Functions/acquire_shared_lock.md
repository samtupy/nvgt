# acquire_shared_lock
Take AngelScript's shared lock, which many threads can hold together but which keeps any of them from taking the exclusive lock.

`void acquire_shared_lock();`

## Remarks:
This is for advanced uses with threads, and must be followed by release_shared_lock().
