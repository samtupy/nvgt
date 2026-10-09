# hold_jitter_threshold
The maximum distance (normalized 0.0-1.0) a finger can move while still being considered stationary for long press detection.

```float hold_jitter_threshold = 0.05f;```

## Remarks:
If a finger moves more than this distance from its starting position, long press and hold events will not trigger.
