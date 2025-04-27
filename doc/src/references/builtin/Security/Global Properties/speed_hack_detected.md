# speed_hack_detected
Attempts to determine if speed-hacking technology is being used.

```nvgt
const atomic_flag speed_hack_detected;
```

## Remarks
This check is performed by the engine every time `wait()` and `refresh_window()` is called and this flag is set whenever the engine can determine that speed-hacking technology is being used. Speed-hacking typically works by hooking low-level operating system timer and time measurement routines to alter the duration of a tick. For the purposes of this description, a tick is an operating system-defined duration which determines how quickly a monotonically increasing timer routine's internal value changes every time that value is requested by the engine. It is strongly recommended that you perform this check immediately after invoking either `wait()` or `refresh_window()`, as the flag is volatile and may change from iteration to iteration.

### Warning
This check is an extention to, and NOT a substitute for, existing speed-hacking detection technology employed by the engine and by any technology you incorporate into your own game. It MUST NOT be solely relied upon to determine if speed-hacking technology is being used. Although the engine does attempt to be as comprehensive as possible without impacting performance to an unreasonable degree, any reasonably advanced adversary will be able to bypass this check.