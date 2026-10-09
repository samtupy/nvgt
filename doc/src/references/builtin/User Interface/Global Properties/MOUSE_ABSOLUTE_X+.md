# MOUSE_ABSOLUTE_X, MOUSE_ABSOLUTE_Y and MOUSE_ABSOLUTE_Z
The current position of the mouse within your game's window, and the total distance its wheel has scrolled.

* `const float MOUSE_ABSOLUTE_X;`
* `const float MOUSE_ABSOLUTE_Y;`
* `const float MOUSE_ABSOLUTE_Z;`

## Remarks:
MOUSE_ABSOLUTE_X and MOUSE_ABSOLUTE_Y are the mouse coordinates relative to the top left corner of your window. They are updated whenever the mouse moves over the window, and are 0 until it does. MOUSE_ABSOLUTE_Z starts at 0 and adds up every scroll of the mouse wheel. Scrolling away from the user usually increases it, though the direction is reversed if the operating system is set to reverse scrolling.

Unlike `MOUSE_X`, `MOUSE_Y` and `MOUSE_Z`, these properties don't depend on `mouse_update()`. They are updated as input arrives, which happens during calls such as `wait()`.

## Example:
```NVGT
void main() {
	show_window("Example");
	wait(50); // Give screen readers time to speak the window title.
	screen_reader_output("Click anywhere in the window to hear where you clicked, or press escape to exit.", true);
	while (!key_pressed(KEY_ESCAPE)) {
		wait(5);
		if (mouse_pressed(1))
			screen_reader_output(round(MOUSE_ABSOLUTE_X, 0) + ", " + round(MOUSE_ABSOLUTE_Y, 0), true);
	}
}
```
