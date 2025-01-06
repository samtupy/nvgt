# is_lock_free
Checks whether the atomic operations on all objects of this type are lock-free.

```nvgt
bool is_lock_free();
```

## Returns:
bool: true if the atomic operations on the objects of this type are lock-free, `false` otherwise.

## Remarks:
This function is available on all atomic types.

All atomic types, with the exception of `atomic_flag`, MAY be implemented utilizing mutexes or alternative locking mechanisms as opposed to employing lock-free atomic instructions provided by the CPU. This allows for the implementation flexibility where atomicity is achieved through synchronization primitives rather than hardware-based atomic instructions.

Atomic types MAY exhibit lock-free behavior under certain conditions. For instance, SHOULD a particular architecture support naturally atomic operations exclusively for aligned memory accesses, then any misaligned instances of the same atomic type MAY necessitate the use of locks to ensure atomicity.

While it is recommended, it is NOT a mandatory requirement that lock-free atomic operations be address-free. Address-free operations are those that are suitable for inter-process communication via shared memory, facilitating seamless data exchange without reliance on specific memory addresses.