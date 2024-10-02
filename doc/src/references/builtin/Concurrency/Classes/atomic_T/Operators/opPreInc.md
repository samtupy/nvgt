# opPreInc
Atomically increments the current value. The operation is a read-modify-write operation. Specifically, performs atomic pre-increment. Equivalent to `return fetch_add(1) + 1;`.

```nvgt
T opPreInc();
```

## Remarks:
This operator is only available on integral atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

Unlike most pre-increment operators, the pre-increment operators for atomic types do not return a reference to the modified object. They return a copy of the stored value instead. 
