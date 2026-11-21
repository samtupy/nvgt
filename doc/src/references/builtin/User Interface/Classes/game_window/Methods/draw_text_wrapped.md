# draw_text_wrapped
Draw text with the window's font, wrapping it onto further lines when it becomes too wide.

`void game_window::draw_text_wrapped(const string&in text, float x, float y, int wrap_width, uint r, uint g, uint b);`

## Arguments:
* const string&in text: the text to draw. Newlines start new lines.
* float x: the horizontal position of the text's top left corner.
* float y: the vertical position of the text's top left corner.
* int wrap_width: the width in pixels at which lines wrap, or 0 to only break lines at newlines.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Remarks:
The alignment of the lines is the font's wrap_alignment.
