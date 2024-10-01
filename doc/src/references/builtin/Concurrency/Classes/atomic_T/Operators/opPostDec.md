# opPostDec
Atomically decrements the current value. The operation is a read-modify-write operation. Specifically, performs atomic post-decrement. Equivalent to `return fetch_add(1);`.

```nvgt
T opPostDec(int arg);
```

## Remarks:
This operator is only available on integral atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

Unlike most post-decrement operators, the post-decrement operators for atomic types do not return a reference to the modified object. They return a copy of the stored value instead. 
