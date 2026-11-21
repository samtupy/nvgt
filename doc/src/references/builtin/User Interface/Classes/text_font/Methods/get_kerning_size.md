# get_kerning_size
Get the kerning between two characters, how much closer or further apart they are drawn than usual.

`bool text_font::get_kerning_size(uint prev_ch, uint ch, int&out kerning) const;`

## Arguments:
* uint prev_ch: the Unicode code point of the first character.
* uint ch: the Unicode code point of the second character.
* int&out kerning: receives the adjustment in pixels.

## Returns:
bool: true on success, false otherwise.
