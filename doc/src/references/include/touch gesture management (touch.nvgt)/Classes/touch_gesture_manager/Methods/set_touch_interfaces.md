# set_touch_interfaces
Sets the list of interfaces that will receive touch events.

```bool set_touch_interfaces(touch_interface@[] interfaces, bool append = false);```

## Arguments:
* touch_interface@[]@ interfaces: A list of interfaces that will receive touch events.
* bool append = false: Determines whether to append to the list of existing interfaces vs. replacing it.

## Returns:
bool: True if a change was made to the interface list, false otherwise.

## Remarks:
You can pass multiple interfaces to a gesture manager because different interfaces can receive different events for various parts of the screen. An interface can simply return false in its is_bounds method at any time to pass the gesture event to the next handler in the chain. Gesture interfaces are evaluated from newest to oldest.
