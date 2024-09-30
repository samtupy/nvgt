Unblocks at least one thread blocked in atomic waiting operations (i.e., `wait()`) on this `atomic_flag`, if there is one; otherwise does nothing.

```nvgt
void notify_one();
```

## Remarks

This form of change detection is often more efficient than pure spinlocks or polling and should be preferred whenever possible.
