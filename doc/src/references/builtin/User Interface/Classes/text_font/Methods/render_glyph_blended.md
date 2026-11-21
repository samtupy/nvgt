# render_glyph_blended
Draw a single character into a new image with smooth edges over a transparent background.

`graphic@ text_font::render_glyph_blended(uint ch, uint r, uint g, uint b);`

## Arguments:
* uint ch: the Unicode code point of the character.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Returns:
graphic@: the image, or null on failure.
