# touch_keyboard_interface
Convert gesture events to simulated keyboard input.

```touch_keyboard_interface(touch_gesture_manager@ parent, dictionary@ map, float minx = TOUCH_UNCOORDINATED, float maxx = TOUCH_UNCOORDINATED, float miny = TOUCH_UNCOORDINATED, float maxy = TOUCH_UNCOORDINATED);```

## Arguments:
* touch_gesture_manager@ parent: A handle to the manager you intend to add this interface to.
* dictionary@ map: A mapping of gestures to keycode lists (see remarks).
* float minx, maxx, miny, maxy = TOUCH_UNCOORDINATED: The bounds of this interface, default for entire screen or custom.

## Remarks:
This interface works by receiving a mapping of gesture names or IDs to lists of keycodes that should be simulated.

The basic format of gesture IDs consists of a gesture name followed by a number of fingers and the letter f. For example, to detect a 2 finger swipe right gesture, you would use the key "swipe_right2f" in the mapping dictionary.

## Available gesture names:

**Basic swipes (4-way):**
* swipe_left
* swipe_right
* swipe_up
* swipe_down

**Diagonal swipes (8-way, requires `touch_enable_8_way_swipes = true`):**
* swipe_up_left
* swipe_up_right
* swipe_down_left
* swipe_down_right

**Taps:**
* single_tap (or just use the numbered versions below)
* double_tap
* tripple_tap
* 4_tap, 5_tap, etc. (for higher tap counts)

**Advanced gestures:**
* flick_left, flick_right, flick_up, flick_down (fast swipes)
* long_press (finger held down without movement)
* Compound swipes (e.g., "swipe_left_up" for an L-shaped gesture)

## Example gesture mappings:
```nvgt
dictionary@ gestures = {
    {"swipe_left1f", KEY_LEFT},           // 1-finger swipe left
    {"swipe_right2f", KEY_RIGHT},         // 2-finger swipe right
    {"double_tap1f", KEY_RETURN},         // Double tap with 1 finger
    {"tripple_tap2f", KEY_ESCAPE},        // Triple tap with 2 fingers
    {"long_press1f", KEY_SPACE},          // Long press with 1 finger
    {"flick_up1f", KEY_PAGEUP}            // Quick flick upward
};
```