# clear
Fill the window with a color, erasing what was drawn.

`bool game_window::clear(uint r, uint g, uint b);`

## Arguments:
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Returns:
bool: true on success, false if the window has no renderer.

## Remarks:
Drawing usually starts with this each frame.
