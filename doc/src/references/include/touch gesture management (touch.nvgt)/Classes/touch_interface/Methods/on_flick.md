# on_flick
Handles flick gestures.

`void on_flick(touch_screen_finger@ finger, int direction, float velocity);`

## Arguments:
* touch_screen_finger@ finger: The finger that performed the flick.
* int direction: The direction of the flick (see swipe_touch_directions enum).
* float velocity: The velocity of the flick in normalized units per second.

## Remarks:
Flicks are detected when a swipe's velocity exceeds `flick_velocity_threshold`.
