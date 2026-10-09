# add_touch_interface
Adds a single interface to the list of interfaces that will receive touch events.

```bool add_touch_interface(touch_interface@ interface);```

## Arguments:
* touch_interface@ interface: The interface to add to the manager.

## Returns:
bool: True if the interface was successfully added, false otherwise.

## Remarks:
You can add multiple interfaces to a gesture manager because different interfaces can receive different events for various parts of the screen. An interface can simply return false in its is_bounds method at any time to pass the gesture event to the next handler in the chain. Gesture interfaces are evaluated from newest to oldest.
