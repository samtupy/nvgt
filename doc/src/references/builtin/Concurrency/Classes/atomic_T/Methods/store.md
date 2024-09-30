Atomically replaces the current value with `desired`. Memory is affected according to the value of `order`.  If order is either MEMORY_ORDER_ACQUIRE or MEMORY_ORDER_ACQ_REL, the behavior is undefined. 

```nvgt
void store(T desired, memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters

* `desired`: the value that should be stored into this atomic object.
* `order`: which memory ordering constraints should be enforced during this operation.

## Remarks

This function is available on all atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

This operation is identical to using the assignment operator, except that it allows for the specification of a memory order when performing this operation. When using the assignment operator, the memory order SHALL be `MEMORY_ORDER_SEQ_CST`.