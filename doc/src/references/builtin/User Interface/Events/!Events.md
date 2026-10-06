# Events
Besides polling functions such as `key_pressed()`, NVGT can notify your code when input arrives by calling functions you register with an event. Each event is a global property, such as `on_key_press`, that holds a list of listeners. Whenever the event happens, NVGT calls the listeners one at a time, in the order they appear in the list.

Events are delivered while NVGT processes input, which happens during calls such as `wait()` and `refresh_window()`. Polling and events can be used together: registering a listener doesn't stop functions like `key_pressed()` from working.

## Adding listeners
A listener can be any of the following:
* A function or method that returns nothing. It is always called, and the event then continues to the next listener.
* A function or method that returns bool. If it returns true, the event is considered handled, and the listeners after it in the list are not called. If it returns false, the event continues to the next listener.
* An object of a class that implements the listener interface for the event, such as `engine_key_event_listener` for key events. The class must have a method named after the event, for example `void on_key_press(int key)` or `bool on_key_press(int key)`, which follows the same rules as above.

Add a listener with the `+=` operator, or with the `insert()` method, which also lets you choose its position in the list:

`bool insert(listener@ listener, int index = -1);`

An index of -1 adds the listener to the end of the list, while 0 makes it the first listener to be called. Both `+=` and `insert()` return false if the listener is already in the list.

## Removing listeners
Remove a listener with the `-=` operator or with `remove(listener)`. You can also remove the listener at a given position with `remove(uint index)`, or every listener with `clear()`. To find a listener's position in the list, use `find(listener)`, which returns -1 if it is not in the list. The `count` property holds the number of listeners.

Object listeners and method listeners only hold a weak reference to their object, so being registered with an event doesn't keep an object alive. Once the object is destroyed, its listener is removed automatically the next time the event fires.

## Available events
* Key events, which pass the key code as an int: `on_key_press`, `on_key_repeat` and `on_key_release`. Their listener interface is `engine_key_event_listener`.
* Text input: `on_characters`, which passes the typed text as a string. Its listener interface is `engine_character_event_listener`.
* Touch events, which pass the touch device and a `touch_finger` structure: `on_touch_finger_down`, `on_touch_finger_up` and `on_touch_finger_cancel`. Their listener interface is `engine_touch_event_listener`.
* Touch movement: `on_touch_finger_move`, which also passes how far the finger moved. Its listener interface is `engine_touch_motion_event_listener`.
