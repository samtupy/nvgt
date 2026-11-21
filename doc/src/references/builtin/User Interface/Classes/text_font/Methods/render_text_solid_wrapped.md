# render_text_solid_wrapped
Draw text into a new image quickly, wrapping it onto further lines when it becomes too wide.

`graphic@ text_font::render_text_solid_wrapped(const string&in text, int wrap_width, uint r, uint g, uint b);`

## Arguments:
* const string&in text: the text to draw.
* int wrap_width: the width in pixels at which lines wrap, or 0 to only break lines at newlines.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Returns:
graphic@: the image, or null on failure.
