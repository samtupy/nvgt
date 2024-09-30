Equals true if this atomic type is always lock-free and false if it is never or sometimes lock-free. 

```nvgt
bool get_is_always_lock_free() property;
```

## Remarks

This property is available on all atomic types. This property is read-only.