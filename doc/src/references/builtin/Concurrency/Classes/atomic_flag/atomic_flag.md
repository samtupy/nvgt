# atomic_flag
An `atomic_flag` is a fundamental synchronization primitive that represents the simplest form of an atomic boolean flag that supports atomic test-and-set and clear operations. The `atomic_flag` type is specifically designed to guarantee atomicity without the need for locks, ensuring that operations on the flag are performed as indivisible actions even in the presence of concurrent threads. Unlike `atomic_bool`, `atomic_flag` does not provide load or store operations.

```nvgt
atomic_flag();
```

## Remarks:
Unlike all other atomic types, `atomic_flag` is guaranteed to be lock-free.
