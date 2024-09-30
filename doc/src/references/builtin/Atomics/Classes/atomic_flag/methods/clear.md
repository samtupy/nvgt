Atomically changes the state of an `atomic_flag` to clear (false). If order is one of MEMORY_ORDER_ACQUIRE or MEMORY_ORDER_ACQ_REL, the behavior is undefined.

```nvgt
void clear(memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters

* `order`: the memory synchronization ordering.
