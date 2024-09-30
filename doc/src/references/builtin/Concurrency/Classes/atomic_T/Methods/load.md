Atomically loads and returns the current value of the atomic variable. Memory is affected according to the value of `order`.  If order is either `MEMORY_ORDER_RELEASE` or `MEMORY_ORDER_ACQ_REL`, the behavior is undefined.

```nvgt
T load(memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters

* `order`: which memory order to enforce when performing this operation.

## Returns

The value of this atomic object.

## Remarks

This function is available on all atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

This operation is identical to using the IMPLICIT CONVERSION OPERATOR, except that it allows for the specification of a memory order when performing this operation. When using the IMPLICIT CONVERSION OPERATOR, the memory order SHALL be `MEMORY_ORDER_SEQ_CST`.