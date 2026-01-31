# on_released_finger
Called when a finger is lifted from the screen.

`void on_released_finger(touch_screen_finger@ finger);`

## Arguments:
* touch_screen_finger@ finger: The finger that was just released.

## Remarks:
This is useful for cleanup operations, such as releasing simulated keys.
