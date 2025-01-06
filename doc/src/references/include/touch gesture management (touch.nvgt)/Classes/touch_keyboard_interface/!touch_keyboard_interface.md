# touch_keyboard_interface
Convert gesture events to simulated keyboard input.

`touch_keyboard_interface(touch_gesture_manager@parent, dictionary@map, float minx = TOUCH_UNCOORDINATED, float maxx = TOUCH_UNCOORDINATED, float miny = TOUCH_UNCOORDINATED, float maxy = TOUCH_UNCOORDINATED);`

## Arguments:
* touch_gesture_manager@ parent: A handle to the manager you intend to add this interface to, parameter subject for removal in future.
* dictionary@ map: A mapping of gestures to keycode lists (see remarks).
* float minx, maxx, miny, maxy = TOUCH_UNCOORDINATED: The bounds of this interface, default for entire screen or custom.

## Remarks:
This interface works by receiving a mapping of gesture names or IDs to lists of keycodes that should be simulated.

The basic format of gesture IDs consists of a gesture name followed by a number of fingers and the letter f. For example, to detect a 2 finger swipe right gesture, you would use the key "swipe_right2f" in the mapping dictionary. The available gesture names are as follows:
* swipe_left
* swipe_right
* swipe_up
* swipe_down
* double_tap
* tripple_tap
