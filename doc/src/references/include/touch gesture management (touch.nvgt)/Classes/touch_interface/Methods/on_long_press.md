# on_long_press
Handles long press gestures.

```
void on_long_press(touch_screen_finger@ finger, uint finger_count);
```

## Remarks:
Triggered once when a finger has been held down for longer than `long_press_time` without moving beyond `hold_jitter_threshold`.
