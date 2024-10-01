# opAssign
Atomically assigns desired to the atomic variable. Equivalent to `store(desired)`.

```nvgt
T opAssign(T desired);
```

## Remarks:
This operator is available on all atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

Unlike most assignment operators, the assignment operators for atomic types do not return a reference to their left-hand arguments. They return a copy of the stored value instead.
