Atomically reads the value of this `atomic_flag` and returns it. The behavior is undefined if the memory order is `MEMORY_ORDER_RELEASE` or `MEMORY_ORDER_ACQ_REL`.

```nvgt
bool test(memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters

* `order`: the memory synchronization ordering.

## Returns

The value atomically read.
