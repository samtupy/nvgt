Atomically loads and returns the current value of the atomic variable. Equivalent to `load()`.

```nvgt
T opImplConv();
```

## Returns

The current value of the atomic variable. 

## Remarks

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.