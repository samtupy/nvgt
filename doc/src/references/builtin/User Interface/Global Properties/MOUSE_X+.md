# MOUSE_X, MOUSE_Y and MOUSE_Z
How far the mouse has moved, and how far its wheel has scrolled, between the two most recent calls to `mouse_update()`.

* `const float MOUSE_X;`
* `const float MOUSE_Y;`
* `const float MOUSE_Z;`

## Remarks:
MOUSE_X and MOUSE_Y are the horizontal and vertical distance the mouse moved, in window coordinates. Positive values mean right and down. MOUSE_Z is how far the mouse wheel scrolled, where positive values usually mean the wheel was scrolled away from the user. If the operating system is set to reverse the scrolling direction (often called natural scrolling), the sign is reversed as well. Some mice and touchpads scroll in fractions of a step.

These values are only recalculated when you call `mouse_update()`, which is not called automatically. Call it once per iteration of your game loop, after `wait()`, and then read these properties. Calling `mouse_update()` more than once per iteration splits the movement between the calls, so later calls see smaller values.

To get the mouse position rather than how far it moved, see `MOUSE_ABSOLUTE_X`, `MOUSE_ABSOLUTE_Y` and `MOUSE_ABSOLUTE_Z`.

## Example:
```NVGT
void main() {
	show_window("Example");
	wait(50); // Give screen readers time to speak the window title.
	screen_reader_output("Scroll the mouse wheel, or press escape to exit.", true);
	while (!key_pressed(KEY_ESCAPE)) {
		wait(5);
		mouse_update();
		if (MOUSE_Z > 0) screen_reader_output("Scrolled up", true);
		else if (MOUSE_Z < 0) screen_reader_output("Scrolled down", true);
	}
}
```
