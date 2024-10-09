# opOrAssign
Atomically replaces the current value with the result of computation involving the previous value and `arg`. The operation is a read-modify-write operation. Specifically, performs atomic bitwise OR. Equivalent to `return fetch_or(arg) | arg;`.

```nvgt
T opOrAssign(T arg);
```

## Returns:
T: The resulting value of this computation.

## Remarks:
This operator is only available on integral atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

Unlike most compound assignment operators, the compound assignment operators for atomic types do not return a reference to their left-hand arguments. They return a copy of the stored value instead. 
