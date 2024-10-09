# exchange
Atomically replaces the value of this object with `desired` in such a way that the operation is a read-modify-write operation, then returns the prior value of this object. Memory is affected according to `order`.

```nvgt
T exchange(T desired, memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters:
* `T desired`: the value to exchange with the prior value.
* `memory_order order`: the memory ordering constraints to enforce.

## Returns
T: The prior value held within this atomic object before this function was called.

## Remarks:
This function is available on all atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.
