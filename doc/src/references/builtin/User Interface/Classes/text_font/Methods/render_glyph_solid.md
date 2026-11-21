# render_glyph_solid
Draw a single character into a new image quickly, without smoothing its edges.

`graphic@ text_font::render_glyph_solid(uint ch, uint r, uint g, uint b);`

## Arguments:
* uint ch: the Unicode code point of the character.
* uint r: the red component of the color, from 0 to 255.
* uint g: the green component of the color, from 0 to 255.
* uint b: the blue component of the color, from 0 to 255.

## Returns:
graphic@: the image, or null on failure.
