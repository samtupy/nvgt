# opImplConv
Atomically loads and returns the current value of the atomic variable. Equivalent to `load()`.

```nvgt
T opImplConv();
```

## Returns:
T: The current value of the atomic variable. 

## Remarks:
This operator is available on all atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.