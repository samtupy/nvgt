# memory_scan_detected
Determines if an application is scanning the address space of your game.

```nvgt
const atomic_flag memory_scan_detected;
```

## Remarks
This flag is set internally by the engine whenever `wait()` or `refresh_window()` are called and it can be determined by the engine that an external process is reading the virtual address space of the process. In some circumstances, writing to the address space by an external process may trigger this check. It is strongly recommended that you perform this check immediately after invoking either `wait()` or `refresh_window()`, as the flag is volatile and may change from iteration to iteration.
