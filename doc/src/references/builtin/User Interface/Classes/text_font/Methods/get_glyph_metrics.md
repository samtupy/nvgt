# get_glyph_metrics
Get the measurements of a character.

`bool text_font::get_glyph_metrics(uint ch, int&out minx, int&out maxx, int&out miny, int&out maxy, int&out advance) const;`

## Arguments:
* uint ch: the Unicode code point of the character.
* int&out minx: receives the left edge of the glyph relative to where it is drawn.
* int&out maxx: receives the right edge of the glyph.
* int&out miny: receives the bottom of the glyph relative to the baseline.
* int&out maxy: receives the top of the glyph relative to the baseline.
* int&out advance: receives how far to move along before drawing the next character.

## Returns:
bool: true on success, false if the font has no such character.
