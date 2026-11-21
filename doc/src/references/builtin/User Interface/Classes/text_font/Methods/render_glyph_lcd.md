# render_glyph_lcd
Draw a single character into a new image with subpixel smoothing over a background color.

`graphic@ text_font::render_glyph_lcd(uint ch, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b);`

## Arguments:
* uint ch: the Unicode code point of the character.
* uint fg_r: the red component of the text color, from 0 to 255.
* uint fg_g: the green component of the text color.
* uint fg_b: the blue component of the text color.
* uint bg_r: the red component of the background color, from 0 to 255.
* uint bg_g: the green component of the background color.
* uint bg_b: the blue component of the background color.

## Returns:
graphic@: the image, or null on failure.
