Unblocks all threads blocked in atomic waiting operations (i.e., `wait()`) on this `atomic_flag`, if there are any; otherwise does nothing.

```nvgt
void notify_all();
```

## Remarks

This form of change detection is often more efficient than pure spinlocks or polling and should be preferred whenever possible.

