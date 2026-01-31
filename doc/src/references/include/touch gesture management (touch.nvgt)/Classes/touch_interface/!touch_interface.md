# touch_interface
Base class for creating custom touch gesture handlers.

```touch_interface(touch_gesture_manager@ parent, float minx = TOUCH_UNCOORDINATED, float maxx = TOUCH_UNCOORDINATED, float miny = TOUCH_UNCOORDINATED, float maxy = TOUCH_UNCOORDINATED);```

## Arguments:
* touch_gesture_manager@ parent: A handle to the manager this interface will be attached to.
* float minx, maxx, miny, maxy = TOUCH_UNCOORDINATED: The bounds of this interface in normalized coordinates (0.0-1.0), default is entire screen.

## Remarks:
This is the base class that all touch interfaces inherit from. You can extend this class to create custom gesture handlers with specialized behavior. The class provides virtual methods for all gesture types that you can override in derived classes.

Any method starting with the word "on_" that you see in the methods list for this base class is meant to be overwridden, such as on_long_press, on_double tap etc.
