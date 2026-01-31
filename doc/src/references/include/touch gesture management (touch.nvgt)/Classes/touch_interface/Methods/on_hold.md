# on_hold
Handles hold gestures.

`void on_hold(touch_screen_finger@ finger, uint finger_count);`

## Arguments:
* touch_screen_finger@ finger: The primary finger that triggered this gesture.
* uint finger_count: The number of fingers that this gesture consists of.

## Remarks:
Triggered continuously while a finger continues to be held down after a long press has been detected.
