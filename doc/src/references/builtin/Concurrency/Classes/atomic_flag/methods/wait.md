# wait
Atomically waits until the value of this `atomic_flag` has changed. If order is either `MEMORY_ORDER_RELEASE` or `MEMORY_ORDER_ACQ_REL`, the behavior is undefined.

```nvgt
void wait(bool old, memory_order order = MEMORY_ORDER_SEQ_CST);
```

## Parameters:
* `old`: The old (current) value of this `atomic_flag` as of the time of this call. This function will wait until this `atomic_flag` no longer contains this value.
* `order`: memory order constraints to enforce.

## Remarks:
This function is guaranteed to return only when the value has changed, even if the underlying implementation unblocks spuriously.
