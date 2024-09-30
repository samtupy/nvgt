Atomically changes the value of this `atomic_flag` to set (`true`) and returns it's prior value.

```nvgt
bool test_and_set(memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters

* `order`: the atomic synchronization order.

## Returns

The prior value of this `atomic_flag`.
