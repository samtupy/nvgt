# get_glyph_image
Get the image of a single character as the font stores it.

`graphic@ text_font::get_glyph_image(uint ch) const;`

## Arguments:
* uint ch: the Unicode code point of the character.

## Returns:
graphic@: the image, or null if the font has no such character.
