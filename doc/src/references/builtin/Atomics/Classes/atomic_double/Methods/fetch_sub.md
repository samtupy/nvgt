Atomically replaces the current value with the result of arithmetic subtraction of the value and `arg`. That is, it performs atomic post-decrement. The operation is a read-modify-write operation. Memory is affected according to the value of `order`.

```nvgt
T fetch_sub(T arg, memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters

* `arg`: the value to subtract from this atomic object.
* `order`: which memory order SHALL govern this operation.

## Returns

The prior value of this atomic object.

## Remarks

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.
