# render_text_lcd_wrapped
Draw text into a new image with subpixel smoothing over a background color, wrapping it onto further lines.

`graphic@ text_font::render_text_lcd_wrapped(const string&in text, int wrap_width, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b);`

## Arguments:
* const string&in text: the text to draw.
* int wrap_width: the width in pixels at which lines wrap, or 0 to only break lines at newlines.
* uint fg_r: the red component of the text color, from 0 to 255.
* uint fg_g: the green component of the text color.
* uint fg_b: the blue component of the text color.
* uint bg_r: the red component of the background color, from 0 to 255.
* uint bg_g: the green component of the background color.
* uint bg_b: the blue component of the background color.

## Returns:
graphic@: the image, or null on failure.
